variable "ghcr_token" {
  description = "Token for GitHub Container Registry coming from GH Secrets"
  type        = string
  sensitive   = true
}

variable "aws_region" {
  description = "AWS region for the provider"
  type        = string
  default     = "us-east-1"
}
