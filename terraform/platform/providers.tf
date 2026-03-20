# providers

# GCP
provider "helm" {
  alias = "gke"
  kubernetes = {
    host                   = data.terraform_remote_state.infra.outputs.gke_endpoint
    cluster_ca_certificate = base64decode(data.terraform_remote_state.infra.outputs.gke_ca_cert)
    token                  = data.terraform_remote_state.infra.outputs.gke_token
  }
}

# AWS
provider "helm" {
  alias = "eks"
  kubernetes = {
    host                   = data.terraform_remote_state.infra.outputs.eks_endpoint
    cluster_ca_certificate = base64decode(data.terraform_remote_state.infra.outputs.eks_ca_cert)
    token                  = data.terraform_remote_state.infra.outputs.eks_token
  }
}

# Rancher bootstrap — used once to init admin + get token
provider "rancher2" {
  alias     = "bootstrap"
  api_url   = "https://${local.rancher_hostname}"
  bootstrap = true
  insecure  = true
}

# Rancher admin — used for all subsequent Rancher resources
provider "rancher2" {
  alias     = "admin"
  api_url   = "https://${local.rancher_hostname}"
  token_key = rancher2_bootstrap.admin.token
  insecure  = true
}
