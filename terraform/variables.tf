variable "ghcr_token" {
  description = "Token for GitHub Container Registry coming from GH Secrets"
  type        = string
  sensitive   = true
}
