# This file will be used to add resources in comments that we could use in the future
# but are not required for the current project

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

terraform {
  backend "local" {}
}

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
