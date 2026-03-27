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
    { name = "providers.kubernetesIngress.allowExternalNameServices", value = "true" },
    { name = "ports.web.http.redirections.entryPoint.to", value = "websecure" },
    { name = "ports.web.http.redirections.entryPoint.scheme", value = "https" },
  ]
  wait    = true
  timeout = 600
}
