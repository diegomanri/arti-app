#data "aws_availability_zones" "available" { state = "available" }
module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 5.2.0"

  #azs                = slice(data.aws_availability_zones.available.names, 0, 2) # Span subnetworks across 2 avalibility zones
  azs                = ["us-east-1a", "us-east-1b"]
  cidr               = "10.0.0.0/16"
  create_igw         = true # Expose public subnetworks to the Internet
  enable_nat_gateway = true # Hide private subnetworks behind NAT Gateway
  private_subnets    = ["10.0.1.0/24", "10.0.2.0/24"]
  public_subnets     = ["10.0.101.0/24", "10.0.102.0/24"]
  single_nat_gateway = true
}

# RDS Security Group
resource "aws_security_group" "rds_sg" {
  name        = "rds-security-group"
  description = "Security group for RDS instance"
  vpc_id      = module.vpc.vpc_id

  ingress {
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    cidr_blocks = ["10.0.1.0/24", "10.0.2.0/24"] # Private subnet CIDR
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Security Group for ALB
resource "aws_security_group" "alb_sg" {
  name        = "alb-security-group"
  description = "Security group for Application Load Balancer"
  vpc_id      = module.vpc.vpc_id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# ECS SG
resource "aws_security_group" "ecs_sg" {
  name        = "ecs-service-sg"
  description = "Security group for ECS services"
  vpc_id      = module.vpc.vpc_id

  # Allow ingress from ALB SG on specific ports
  ingress {
    from_port       = 8000
    to_port         = 8001
    protocol        = "tcp"
    security_groups = [aws_security_group.alb_sg.id] # Reference to the custom ALB SG
  }

  # Allow egress to RDS SG on the database port
  egress {
    from_port       = 5432
    to_port         = 5432
    protocol        = "tcp"
    security_groups = [aws_security_group.rds_sg.id] # Replace with your RDS SG ID
  }

  # Additional egress rule to allow outbound internet access, if needed
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Load Balancer
# ./main.tf

module "alb" {
  source  = "terraform-aws-modules/alb/aws"
  version = "~> 9.2.0"

  load_balancer_type         = "application"
  security_groups            = [aws_security_group.alb_sg.id]
  subnets                    = module.vpc.public_subnets
  vpc_id                     = module.vpc.vpc_id
  name                       = "arti-app-alb"
  enable_deletion_protection = false

  listeners = [
    {
      port               = 80
      protocol           = "HTTP"
      target_group_index = 0
    },
    {
      port               = 443
      protocol           = "HTTPS"
      target_group_index = 0
    }
  ]

  target_groups = {
    nginx_target_group = {
      backend_port                      = 8000 # Nginx port
      backend_protocol                  = "HTTP"
      target_type                       = "ip"
      load_balancing_cross_zone_enabled = false
      # There's nothing to attach here in this definition. Instead,
      # ECS will attach the IPs of the tasks to this target group
      create_attachment = false
      health_check = {
        enabled             = true
        healthy_threshold   = 5
        interval            = 30
        matcher             = "200"
        path                = "/"
        port                = "traffic-port"
        protocol            = "HTTP"
        timeout             = 5
        unhealthy_threshold = 2
      }
    }
  }
}
