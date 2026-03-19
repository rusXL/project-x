# register EKS as an imported cluster in Rancher

resource "rancher2_cluster" "rancher_cluster_a" {
  provider    = rancher2
  name        = "cluster-a"
  description = "AWS EKS cluster"
}
