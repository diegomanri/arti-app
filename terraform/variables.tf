variable "ghcr_token" {
  description = "Token for GitHub Container Registry coming from GH Secrets"
  type        = string
  sensitive   = true
}

variable "ghcr_user" {
  description = "Username for GitHub Container Registry coming from GH Secrets"
  type        = string
  sensitive   = true
}


variable "aws_region" {
  description = "AWS region for the provider"
  type        = string
  default     = "us-east-1"
}

# The following are empty now because I want to apply them from Github Secrets
variable "db_user" {}
variable "db_password" {}
variable "db_host" {}
variable "db_name" {}
variable "prod_django_secret_key" {}
