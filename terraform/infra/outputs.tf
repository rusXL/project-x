# GKE
output "gke_endpoint" {
  value     = module.gke.gke_endpoint
  sensitive = true
}
output "gke_ca_cert" {
  value     = module.gke.gke_ca_cert
  sensitive = true
}
output "gke_token" {
  value     = module.gke.gke_token
  sensitive = true
}
output "gke_lb_ip" {
  value = module.gke.gke_lb_ip
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
output "eks_token" {
  value     = module.eks.eks_token
  sensitive = true
}
