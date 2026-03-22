# root

module "gke" {
  source = "./gke"
  providers = {
    google = google
  }
  gcp_region      = var.gcp_region
  gcp_zone        = var.gcp_zone
  gcp_subnet_cidr = var.gcp_subnet_cidr
  gcp_node_count  = var.gcp_node_count
  aws_vpc_cidr    = var.aws_vpc_cidr
}

module "eks" {
  source = "./eks"
  providers = {
    aws = aws
  }
  aws_zone          = var.aws_zone
  aws_vpc_cidr      = var.aws_vpc_cidr
  aws_subnet_cidr   = var.aws_subnet_cidr
  aws_node_count    = var.aws_node_count
  gcp_vpc_cidr      = var.gcp_subnet_cidr
  gcp_pod_cidr      = module.gke.gke_pod_cidr
  aws_subnet_b_cidr = var.aws_subnet_b_cidr
  aws_zone_b        = var.aws_zone_b
}

module "dns" {
  source = "./dns"
  providers = {
    aws    = aws
    google = google
  }
  vpc_a_id       = module.eks.vpc_a_id
  subnet_a_id    = module.eks.subnet_a_id
  subnet_b_id    = module.eks.subnet_b_id
  vpc_g_id        = module.gke.vpc_g_id
  gcp_subnet_cidr = var.gcp_subnet_cidr
  aws_vpc_cidr    = var.aws_vpc_cidr
}


module "vpn" {
  source = "./vpn"
  providers = {
    google = google
    aws    = aws
  }
  vpc_g_id         = module.gke.vpc_g_id
  vpc_a_id         = module.eks.vpc_a_id
  route_table_a_id = module.eks.route_table_a_id
  gcp_project_id   = var.gcp_project_id
  gcp_region       = var.gcp_region
  vpn_psk          = var.vpn_psk
}
