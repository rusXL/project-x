# terraform config

terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 6.20"
    }
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.80"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "~> 3.1"
    }
  }

  required_version = ">= 1.5"
}
