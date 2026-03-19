# firewall rules

resource "google_compute_firewall" "allow_from_aws" {
  name    = "allow-from-aws"
  network = google_compute_network.vpc_g.id

  allow {
    protocol = "all"
  }

  source_ranges = [var.aws_vpc_cidr]
}
