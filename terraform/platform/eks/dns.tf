# api.project-x CNAME -> Traefik internal ELB on EKS

data "kubernetes_service" "traefik" {
  metadata {
    name      = "traefik"
    namespace = "traefik"
  }
  depends_on = [helm_release.traefik_a]
}

resource "aws_route53_record" "api" {
  zone_id = var.aws_zone_id
  name    = "api.project-x"
  type    = "CNAME"
  ttl     = 60
  records = [data.kubernetes_service.traefik.status[0].load_balancer[0].ingress[0].hostname]
}

resource "aws_route53_record" "grafana" {
  zone_id = var.aws_zone_id
  name    = "grafana.project-x"
  type    = "CNAME"
  ttl     = 60
  records = [data.kubernetes_service.traefik.status[0].load_balancer[0].ingress[0].hostname]
}
