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

# Attach policies to the IAM role/user/group as that will be used to run Terraform
# Commenting out as the ACloudGuru Sandbox user should have the required permissions

# IAM Policy for S3 Bucket Access
# resource "aws_iam_policy" "terraform_state_s3" {
#   name        = "TerraformStateS3Access"
#   description = "Policy to access the S3 bucket for Terraform State"

#   policy = jsonencode({
#     Version = "2012-10-17",
#     Statement = [
#       {
#         Effect   = "Allow",
#         Action   = ["s3:*"],
#         Resource = [aws_s3_bucket.terraform_state.arn]
#       }
#     ]
#   })
# }

# S3 and DynamoDB for Terraform State are created dynamically in the tf-state-setup.yml GitHub Action workflow
# so we no longer need to have it defined in the Terraform code

# # IAM Policy for DynamoDB Table Access
# resource "aws_iam_policy" "terraform_state_dynamodb" {
#   name        = "TerraformStateDynamoDBAccess"
#   description = "Policy to access the DynamoDB table for Terraform State Locking"

#   policy = jsonencode({
#     Version = "2012-10-17",
#     Statement = [
#       {
#         Effect   = "Allow",
#         Action   = ["dynamodb:*"],
#         Resource = [aws_dynamodb_table.terraform_state_lock.arn]
#       }
#     ]
#   })
# }

# This file will contain the configuration for the S3 bucket and DynamoDB table for Terraform state

# Create a random string for unique bucket name
# resource "random_string" "bucket_suffix" {
#   length  = 8
#   special = false
#   upper   = false
# }

# # S3 Bucket for Terraform State
# resource "aws_s3_bucket" "terraform_state" {
#   bucket = "terraform-state-${random_string.bucket_suffix.result}"

#   versioning {
#     enabled = true
#   }

#   # Enable server-side encryption
#   server_side_encryption_configuration {
#     rule {
#       apply_server_side_encryption_by_default {
#         sse_algorithm = "AES256"
#       }
#     }
#   }
# }

# DynamoDB Table for Terraform State Locking
# resource "aws_dynamodb_table" "terraform_state_lock" {
#   name         = "terraform-state-lock"
#   billing_mode = "PAY_PER_REQUEST"
#   hash_key     = "LockID"

#   attribute {
#     name = "LockID"
#     type = "S"
#   }
# }

# Outputs
# output "s3_bucket_name" {
#   value = aws_s3_bucket.terraform_state.id
# }

# output "dynamodb_table_name" {
#   value = aws_dynamodb_table.terraform_state_lock.id
# }
