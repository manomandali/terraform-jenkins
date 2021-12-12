terraform {
  required_version = ">= 1.0.10"

  backend "s3" {
    bucket               = "bizwithai-admin-terraform"
    workspace_key_prefix = "fargate-eks"
    key                  = "platform/modules"
    region               = "ap-south-1"
    profile              = "bizwithai-admin"
  }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 3.63.0"
    }

    local = {
      source  = "hashicorp/local"
      version = ">= 1.4"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = ">= 1.11.1"
    }

    tls = {
      source  = "hashicorp/tls"
      version = ">= 2.0"
    }
  }
}