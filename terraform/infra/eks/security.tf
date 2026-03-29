# auth, security group

resource "aws_security_group_rule" "allow_http_from_gcp" {
  type              = "ingress"
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  cidr_blocks       = [var.gcp_vpc_cidr, var.gcp_pod_cidr]
  security_group_id = aws_eks_cluster.cluster_a.vpc_config[0].cluster_security_group_id
  description       = "HTTP from GCP (frontend -> API, Grafana proxy via Traefik)"
}
