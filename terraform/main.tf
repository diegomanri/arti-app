data "aws_availability_zones" "available" { state = "available" }
module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 5.2.0"

  azs                = slice(data.aws_availability_zones.available.names, 0, 1) # Span subnetworks across 2 avalibility zones
  cidr               = "10.0.0.0/16"
  create_igw         = true # Expose public subnetworks to the Internet
  enable_nat_gateway = true # Hide private subnetworks behind NAT Gateway
  private_subnets    = ["10.0.1.0/24"]
  public_subnets     = ["10.0.101.0/24"]
  single_nat_gateway = true
}

# Load Balancer

# TODO - Add S3 resources to store TF state and lock files

# Random password generator resource
resource "random_password" "rds_pass" {
  length  = 16
  special = true
}

# AWS Secrets Manager
#RDS Password
resource "aws_secretsmanager_secret" "rds_password" {
  name = "rds_password"
}

resource "aws_secretsmanager_secret_version" "rds_password" {
  secret_id     = aws_secretsmanager_secret.rds_password.id
  secret_string = random_password.rds_pass.result
}
# GHCR Token
resource "aws_secretsmanager_secret" "ghcr_token" {
  name = "ghcr_token"
}

resource "aws_secretsmanager_secret_version" "ghcr_token" {
  secret_id     = aws_secretsmanager_secret.ghcr_token.id
  secret_string = var.ghcr_token
}

# RDS Instance

# AWS Parameter Store
# rds_username
resource "aws_ssm_parameter" "rds_username" {
  name  = "/myapp/db_username"
  type  = "String"
  value = "your_db_username"
}

# rds_db_name
resource "aws_ssm_parameter" "rds_db_name" {
  name  = "/myapp/db_name"
  type  = "String"
  value = "your_db_name"
}

# rds_host
resource "aws_ssm_parameter" "rds_host" {
  name  = "/myapp/db_username"
  type  = "String"
  value = "your_db_username"
}

# RDS Database

# ECS Fargate Cluster

# ECS IAM Role

# ECS Fargate Task Definition
# Here I believe is where we would define the environment variables for the container

# Cloudfront Distribution
