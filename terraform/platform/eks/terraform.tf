terraform {
  required_providers {
    helm = {
      source = "hashicorp/helm"
    }
    rancher2 = {
      source = "rancher/rancher2"
    }
    aws = {
      source = "hashicorp/aws"
    }
    kubernetes = {
      source = "hashicorp/kubernetes"
    }
  }
}
