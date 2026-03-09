# outputs

output "cluster_endpoint" {
  description = "GKE cluster API endpoint (for kubectl)"
  value       = google_container_cluster.cluster.endpoint
  sensitive   = true
}

output "ingress_lb_ip" {
  description = "External IP of the ingress-nginx LoadBalancer"
  value       = local.lb_ip
}

output "rancher_url" {
  description = "Rancher UI"
  value       = "https://${local.rancher_hostname}"
}

