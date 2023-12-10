# Provider setup only for state management

provider "aws" {
  region = "us-east-1"
}

terraform {
  required_version = "~> 1.5"

  backend "s3" {
    bucket         = "terraform-state-${random_string.bucket_suffix.result}"
    key            = "state/production/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "terraform-state-lock"
    encrypt        = true
  }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.26"
    }
  }
}