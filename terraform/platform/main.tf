# root
module "gke" {
  source = "./gke"
  providers = {
    helm = helm.gke
  }
  gke_lb_ip = var.gke_lb_ip

  rancher_hostname       = var.rancher_hostname
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
    helm     = helm.eks
    rancher2 = rancher2.admin
  }
  rancher_hostname = var.rancher_hostname
  rancher_token    = rancher2_bootstrap.admin.token

  depends_on = [module.gke]
}
