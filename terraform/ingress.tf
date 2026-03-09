# ingress
resource "kubernetes_namespace_v1" "ingress_nginx" {
  metadata {
    name = "ingress-nginx"
  }
  depends_on = [google_container_node_pool.node_pool]
}

resource "helm_release" "ingress_nginx" {
  name       = "ingress-nginx"
  repository = "https://kubernetes.github.io/ingress-nginx"
  chart      = "ingress-nginx"
  version    = "4.0.18"

  namespace = kubernetes_namespace_v1.ingress_nginx.metadata[0].name

  set = [{
    name  = "controller.service.type"
    value = "LoadBalancer"
  }]

  wait    = true
  timeout = 600

  depends_on = [kubernetes_namespace_v1.ingress_nginx]
}
