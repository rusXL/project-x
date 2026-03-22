# providers

provider "google" {
  project = "cloud-computing-476715"
  region  = "us-central1"
}

provider "aws" {
  region = "us-east-1"
}

data "google_client_config" "default" {}

data "aws_eks_cluster_auth" "cluster_a" {
  name = "cluster-a"
}

# GCP
provider "helm" {
  alias = "gke"
  kubernetes = {
    host                   = data.terraform_remote_state.infra.outputs.gke_endpoint
    cluster_ca_certificate = base64decode(data.terraform_remote_state.infra.outputs.gke_ca_cert)
    token                  = data.google_client_config.default.access_token
  }
}

# AWS
provider "helm" {
  alias = "eks"
  kubernetes = {
    host                   = data.terraform_remote_state.infra.outputs.eks_endpoint
    cluster_ca_certificate = base64decode(data.terraform_remote_state.infra.outputs.eks_ca_cert)
    token                  = data.aws_eks_cluster_auth.cluster_a.token
  }
}

provider "kubernetes" {
  alias                  = "eks"
  host                   = data.terraform_remote_state.infra.outputs.eks_endpoint
  cluster_ca_certificate = base64decode(data.terraform_remote_state.infra.outputs.eks_ca_cert)
  token                  = data.aws_eks_cluster_auth.cluster_a.token
}

# Rancher bootstrap — used once to init admin + get token
provider "rancher2" {
  alias     = "bootstrap"
  api_url   = "https://${local.rancher_hostname}"
  bootstrap = true
}

# Rancher admin — used for all subsequent Rancher resources
provider "rancher2" {
  alias     = "admin"
  api_url   = "https://${local.rancher_hostname}"
  token_key = rancher2_bootstrap.admin.token
}
