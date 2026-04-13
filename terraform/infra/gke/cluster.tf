# k8s clusters

resource "google_container_cluster" "cluster_g" {
  name     = "cluster-g"
  location = var.gcp_zone

  min_master_version       = "1.34"
  remove_default_node_pool = true
  initial_node_count       = 1
  deletion_protection      = false

  network    = google_compute_network.vpc_g.name
  subnetwork = google_compute_subnetwork.subnet_g.name
}

resource "google_container_node_pool" "node_pool_g" {
  name     = "node-pool-g"
  location = var.gcp_zone
  cluster  = google_container_cluster.cluster_g.name

  node_count = var.gcp_node_count

  node_config {
    preemptible  = false
    machine_type = var.gcp_machine_type
  }
}
