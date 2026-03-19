# ingress controller

resource "helm_release" "traefik" {
  name             = "traefik"
  repository       = "https://traefik.github.io/charts"
  chart            = "traefik"
  version          = "39.0.0"
  namespace        = "traefik"
  create_namespace = true
  set = [
    { name = "service.type", value = "LoadBalancer" },
    {
      name  = "service.annotations.networking\\.gke\\.io/load-balancer-ip-addresses"
      value = "lb-ip"
    },
    {
      name  = "service.annotations.cloud\\.google\\.com/l4-rbs"
      value = "enabled"
    },
  ]
  wait    = true
  timeout = 600
}
