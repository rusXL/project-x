# providers

# GCP
provider "helm" {
  alias = "gke"
  kubernetes = {
    host                   = var.gke_endpoint
    cluster_ca_certificate = base64decode(var.gke_ca_cert)
    token                  = var.gke_token
  }
}

# AWS
provider "helm" {
  alias = "eks"
  kubernetes = {
    host                   = var.eks_endpoint
    cluster_ca_certificate = base64decode(var.eks_ca_cert)
    token                  = var.eks_token
  }
}

# Rancher bootstrap — used once to init admin + get token
provider "rancher2" {
  alias     = "bootstrap"
  api_url   = "https://${var.rancher_hostname}"
  bootstrap = true
  insecure  = true
}

# Rancher admin — used for all subsequent Rancher resources
provider "rancher2" {
  alias     = "admin"
  api_url   = "https://${var.rancher_hostname}"
  token_key = rancher2_bootstrap.admin.token
  insecure  = true
}
