# k8s clusters

resource "google_container_cluster" "cluster" {
  name     = "cluster"
  location = var.gcp_zone

  remove_default_node_pool = true
  initial_node_count       = 1
  deletion_protection      = false

  network    = google_compute_network.vpc.name
  subnetwork = google_compute_subnetwork.subnet.name
}

resource "google_container_node_pool" "node_pool" {
  name     = "node-pool"
  location = var.gcp_zone
  cluster  = google_container_cluster.cluster.name

  node_count = 1

  node_config {
    preemptible  = true # TODO: change in prod
    machine_type = "e2-medium"
  }
}
