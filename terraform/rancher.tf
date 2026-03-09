# rancher

data "kubernetes_service_v1" "ingress_nginx_lb" {
  metadata {
    name      = "ingress-nginx-controller"
    namespace = kubernetes_namespace_v1.ingress_nginx.metadata[0].name
  }
  depends_on = [helm_release.ingress_nginx]
}

locals {
  lb_ip            = data.kubernetes_service_v1.ingress_nginx_lb.status[0].load_balancer[0].ingress[0].ip
  rancher_hostname = var.rancher_hostname != "" ? var.rancher_hostname : "${local.lb_ip}.nip.io"
}

resource "kubernetes_namespace_v1" "cattle_system" {
  metadata {
    name = "cattle-system"
  }
  depends_on = [google_container_node_pool.node_pool]
}

resource "helm_release" "rancher" {
  name       = "rancher"
  repository = "https://releases.rancher.com/server-charts/stable"
  chart      = "rancher"
  namespace  = kubernetes_namespace_v1.cattle_system.metadata[0].name

  set = [
    {
      name  = "bootstrapPassword"
      value = var.rancher_bootstrap_password
    },
    {
      name  = "hostname"
      value = local.rancher_hostname
    },
    {
      name  = "tls"
      value = "external"
    },
    {
      name  = "ingress.ingressClassName"
      value = "nginx"
    }
  ]

  wait    = true
  timeout = 600

  depends_on = [
    helm_release.ingress_nginx,
    kubernetes_namespace_v1.cattle_system,
  ]
}

