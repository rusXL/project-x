output "eks_endpoint" {
  value     = aws_eks_cluster.cluster_a.endpoint
  sensitive = true
}

output "eks_ca_cert" {
  value     = aws_eks_cluster.cluster_a.certificate_authority[0].data
  sensitive = true
}


output "vpc_a_id" {
  value = aws_vpc.vpc_a.id
}

output "route_table_a_id" {
  value = aws_route_table.rt_a.id
}
