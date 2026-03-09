# networks

resource "google_compute_network" "vpc" {
  name                    = "vpc"
  auto_create_subnetworks = false
  routing_mode            = "GLOBAL"
}

resource "google_compute_subnetwork" "subnet" {
  name          = "subnet"
  network       = google_compute_network.vpc.id
  region        = var.gcp_region
  ip_cidr_range = var.gcp_subnet_cidr
}
