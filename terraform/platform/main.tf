# root

data "terraform_remote_state" "infra" {
  backend = "local"
  config = {
    path = "../infra/terraform.tfstate"
  }
}

locals {
  rancher_hostname = "rancher.${data.terraform_remote_state.infra.outputs.gke_lb_ip}.nip.io"
}

module "gke" {
  source = "./gke"
  providers = {
    helm = helm.gke
  }
  gke_lb_ip = data.terraform_remote_state.infra.outputs.gke_lb_ip

  rancher_hostname       = local.rancher_hostname
  rancher_admin_password = var.rancher_admin_password
}

resource "rancher2_bootstrap" "admin" {
  provider         = rancher2.bootstrap
  initial_password = var.rancher_admin_password
  password         = var.rancher_admin_password

  depends_on = [module.gke]
}

module "eks" {
  source = "./eks"
  providers = {
    helm       = helm.eks
    rancher2   = rancher2.admin
    aws        = aws
    kubernetes = kubernetes.eks
  }

  rancher_hostname = local.rancher_hostname
  rancher_token    = rancher2_bootstrap.admin.token
  aws_zone_id      = data.terraform_remote_state.infra.outputs.route53_zone_id

  depends_on = [rancher2_bootstrap.admin]
}
