# providers

# GCP
provider "google" {
  project = var.gcp_project_id
  region  = var.gcp_region
}

# AWS
provider "aws" {
  region = var.aws_region
}

