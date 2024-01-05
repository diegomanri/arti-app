locals {
  # TODO: Need to change to GHCR
  #repository_url = "ghcr.io/jimmysawczuk/sun-api"
}

# We need a cluster in which to put our service.
resource "aws_ecs_cluster" "arti_app" {
  name = "arti-app"
}

# An ECR repository is a private alternative to Docker Hub.
# TODO: Will be changing to GHCR.
# resource "aws_ecr_repository" "arti_app" {
#   name = "arti-app"
# }

# Log groups hold logs from our app.
resource "aws_cloudwatch_log_group" "arti_app" {
  name = "/ecs/arti-app"
}

# The main service.
resource "aws_ecs_service" "arti_app" {
  name            = "arti-app"
  task_definition = aws_ecs_task_definition.arti_app.arn
  cluster         = aws_ecs_cluster.arti_app.id
  launch_type     = "FARGATE"

  desired_count = 1

  load_balancer {
    # TODO: I need to find out what the target_group_arn output would be for my ALB module
    # According to TF docs this works https://github.com/terraform-aws-modules/terraform-aws-ecs/blob/v5.7.3/examples/fargate/main.tf
    target_group_arn = module.alb.target_groups["nginx_target_group"].arn

    container_name = "nginx" #Nginx would be here as this is whats exposed to the ALB
    container_port = 8000
  }

  network_configuration {
    assign_public_ip = false

    security_groups = [
      aws_security_group.ecs_sg.id
    ]

    subnets = module.vpc.private_subnets
  }
}

# The task definition for our app.
resource "aws_ecs_task_definition" "arti_app" {
  family             = "arti-app"
  execution_role_arn = aws_iam_role.arti_app_task_execution_role.arn

  # These are the minimum values for Fargate containers.
  cpu                      = 256
  memory                   = 512
  requires_compatibilities = ["FARGATE"]

  # This is required for Fargate containers (more on this later).
  network_mode = "awsvpc"

  container_definitions = jsonencode([
    {
      name  = "nginx"
      image = "ghcr.io/diegomanri/arti-app/nginx:latest",
      "repositoryCredentials" : {
        "credentialsParameter" : aws_secretsmanager_secret.ghcr_credentials.arn
      }
      portMappings = [
        {
          containerPort = 8000
          hostPort      = 8000
        }
      ],
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          "awslogs-group"         = aws_cloudwatch_log_group.arti_app.name,
          "awslogs-region"        = "us-east-1",
          "awslogs-stream-prefix" = "nginx"
        }
      }
    },
    {
      name  = "django"
      image = "ghcr.io/diegomanri/arti-app/django:latest",
      "repositoryCredentials" : {
        "credentialsParameter" : aws_secretsmanager_secret.ghcr_credentials.arn
      }
      portMappings = [
        {
          containerPort = 8001
          hostPort      = 8001
        }
      ],
      environment = [
        {
          name  = "PROD_DJANGO_SECRET_KEY",
          value = var.prod_django_secret_key
        },
        {
          name  = "DATABASE_USERNAME",
          value = var.db_user
        },
        {
          name  = "DATABASE_HOST",
          value = aws_db_instance.artiapp_db.endpoint
        },
        {
          name  = "DATABASE_NAME",
          value = var.db_name
        },
        {
          name  = "DATABASE_PASSWORD",
          value = var.db_password
        }
      ],
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          "awslogs-group"         = aws_cloudwatch_log_group.arti_app.name,
          "awslogs-region"        = "us-east-1",
          "awslogs-stream-prefix" = "django"
        }
      }
    }
  ])

  # This is the original container definition for the sun-api container.
  #   container_definitions = <<EOF
  #   [
  #     {
  #       "name": "sun-api",
  #       "image": "${local.repository_url == "" ? aws_ecr_repository.sun_api.repository_url : local.repository_url}:latest",
  #       "portMappings": [
  #         {
  #           "containerPort": 3000
  #         }
  #       ],
  #       "logConfiguration": {
  #         "logDriver": "awslogs",
  #         "options": {
  #           "awslogs-region": "us-east-1",
  #           "awslogs-group": "/ecs/sun-api",
  #           "awslogs-stream-prefix": "ecs"
  #         }
  #       }
  #     }
  #   ]

  # EOF
}

# This is the role under which ECS will execute our task. This role becomes more important
# as we add integrations with other AWS services later on.

# The assume_role_policy field works with the following aws_iam_policy_document to allow
# ECS tasks to assume this role we're creating.
resource "aws_iam_role" "arti_app_task_execution_role" {
  name               = "arti-app-task-execution-role"
  assume_role_policy = data.aws_iam_policy_document.ecs_task_assume_role.json
}

data "aws_iam_policy_document" "ecs_task_assume_role" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }
  }
}

# IAM Policy Document for ECS Task Execution: Define necessary permissions
data "aws_iam_policy_document" "ecs_task_execution_role_policy" {
  # Updated to include SSM and/or Secrets Manager permissions
  statement {
    actions = [
      "secretsmanager:GetSecretValue", # For Secrets Manager
      "kms:Decrypt",                   # To decrypt the secret
      "ecr:GetAuthorizationToken",
      "ecr:BatchCheckLayerAvailability",
      "ecr:GetDownloadUrlForLayer",
      "ecr:BatchGetImage",
      "logs:CreateLogStream",
      "logs:PutLogEvents"
    ]
    resources = [
      # Specify the resources for SSM and Secrets Manager here, use * for all or restrict as needed
      # "arn:aws:ssm:${var.aws_region}:${data.aws_caller_identity.current.account_id}:parameter/*",
      # "arn:aws:secretsmanager:${var.aws_region}:${data.aws_caller_identity.current.account_id}:secret:*"
      "*" # For all resources (for now as I am troubleshooting)
    ]
  }
}

# Normally we'd prefer not to hardcode an ARN in our Terraform, but since this is an AWS-managed
# policy, it's okay.
# data "aws_iam_policy" "ecs_task_execution_policy" {
#   arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
# }

resource "aws_iam_policy" "ecs_task_execution_policy" {
  name   = "arti-app-task-execution-policy"
  policy = data.aws_iam_policy_document.ecs_task_execution_role_policy.json
}

# Attach the above policy to the execution role.
resource "aws_iam_role_policy_attachment" "ecs_task_execution_role" {
  role = aws_iam_role.arti_app_task_execution_role.name
  #policy_arn = data.aws_iam_policy.ecs_task_execution_policy.arn
  policy_arn = aws_iam_policy.ecs_task_execution_policy.arn
}
# Some of this below comes from vpc.tf already, some other things I don't want to implement yet
# Like the certificate and the domain name.

# resource "aws_lb_target_group" "sun_api" {
#   name        = "sun-api"
#   port        = 3000
#   protocol    = "HTTP"
#   target_type = "ip"
#   vpc_id      = aws_vpc.app_vpc.id

#   health_check {
#     enabled = true
#     path    = "/health"
#   }

#   depends_on = [aws_alb.sun_api]
# }

# resource "aws_alb" "sun_api" {
#   name               = "sun-api-lb"
#   internal           = false
#   load_balancer_type = "application"

#   subnets = [
#     aws_subnet.public_d.id,
#     aws_subnet.public_e.id,
#   ]

#   security_groups = [
#     aws_security_group.http.id,
#     aws_security_group.https.id,
#     aws_security_group.egress_all.id,
#   ]

#   depends_on = [aws_internet_gateway.igw]
# }

# resource "aws_alb_listener" "sun_api_http" {
#   load_balancer_arn = aws_alb.sun_api.arn
#   port              = "80"
#   protocol          = "HTTP"

#   default_action {
#     type = "redirect"

#     redirect {
#       port        = "443"
#       protocol    = "HTTPS"
#       status_code = "HTTP_301"
#     }
#   }
# }

# resource "aws_alb_listener" "sun_api_https" {
#   load_balancer_arn = aws_alb.sun_api.arn
#   port              = "443"
#   protocol          = "HTTPS"
#   certificate_arn   = aws_acm_certificate.sun_api.arn

#   default_action {
#     type             = "forward"
#     target_group_arn = aws_lb_target_group.sun_api.arn
#   }
# }

# output "alb_url" {
#   value = "http://${aws_alb.sun_api.dns_name}"
# }

# resource "aws_acm_certificate" "sun_api" {
#   domain_name       = "sun-api.jimmysawczuk.net"
#   validation_method = "DNS"
# }

# output "domain_validations" {
#   value = aws_acm_certificate.sun_api.domain_validation_options
# }
