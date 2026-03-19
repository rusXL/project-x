output "eks_registration_manifest" {
  value = rancher2_cluster.rancher_cluster_a.cluster_registration_token[0].manifest_url
}
