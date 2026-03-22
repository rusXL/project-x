# GKE
output "gke_endpoint" {
  value     = module.gke.gke_endpoint
  sensitive = true
}
output "gke_ca_cert" {
  value     = module.gke.gke_ca_cert
  sensitive = true
}

output "gke_lb_ip" {
  value = module.gke.gke_lb_ip
}

output "route53_zone_id" {
  value = module.dns.route53_zone_id
}

# EKS
output "eks_endpoint" {
  value     = module.eks.eks_endpoint
  sensitive = true
}
output "eks_ca_cert" {
  value     = module.eks.eks_ca_cert
  sensitive = true
}

