data "google_client_config" "default" {}

output "gke_endpoint" {
  value     = google_container_cluster.cluster_g.endpoint
  sensitive = true
}

output "gke_ca_cert" {
  value     = google_container_cluster.cluster_g.master_auth[0].cluster_ca_certificate
  sensitive = true
}

output "vpc_g_id" {
  value = google_compute_network.vpc_g.id
}

output "gke_pod_cidr" {
  value = google_container_cluster.cluster_g.cluster_ipv4_cidr
}

output "gke_token" {
  value     = data.google_client_config.default.access_token
  sensitive = true
}

output "gke_lb_ip" {
  value = google_compute_address.lb_ip.address
}
