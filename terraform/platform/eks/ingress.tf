# ingress controller

resource "helm_release" "traefik_a" {
  name             = "traefik"
  repository       = "https://traefik.github.io/charts"
  chart            = "traefik"
  version          = "39.0.0"
  namespace        = "traefik"
  create_namespace = true
  set = [
    { name = "service.type", value = "LoadBalancer" },
    {
      name  = "service.annotations.service\\.beta\\.kubernetes\\.io/aws-load-balancer-internal"
      value = "true"
      type  = "string"
    }
  ]
  wait    = true
  timeout = 600
}
