# terraform config

terraform {
  required_providers {
    helm = {
      source  = "hashicorp/helm"
      version = "~> 3.1"
    }
    rancher2 = {
      source  = "rancher/rancher2"
      version = "~> 13.0"
    }
  }

  required_version = ">= 1.5"
}
