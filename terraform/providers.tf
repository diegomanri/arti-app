# Provider setup for the arti-app application infrastructure in AWS

provider "aws" {
  region = "us-east-1"
}

terraform {
  required_version = "~> 1.5"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.26"
    }
    docker = {
      source  = "kreuzwerker/docker"
      version = "3.0.2"
    }
  }
}

provider "docker" {
  registry_auth {
    address  = "ghcr.io"
    username = "diegomanri"
    password = var.ghcr_token # GHCR token from Terraform variable
  }
}
