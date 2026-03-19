# networks

resource "google_compute_network" "vpc_g" {
  name                    = "vpc-g"
  auto_create_subnetworks = false
  routing_mode            = "GLOBAL"
}

resource "google_compute_subnetwork" "subnet_g" {
  name          = "subnet-g"
  network       = google_compute_network.vpc_g.id
  ip_cidr_range = var.gcp_subnet_cidr
}

resource "google_compute_address" "lb_ip" {
  name   = "lb-ip"
  region = var.gcp_region
}
