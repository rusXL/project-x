# rancher management cluster

resource "helm_release" "rancher" {
  name             = "rancher"
  repository       = "https://releases.rancher.com/server-charts/stable"
  chart            = "rancher"
  version          = "2.13.3"
  namespace        = "cattle-system"
  create_namespace = true
  depends_on       = [helm_release.cert_manager]
  set = [
    { name = "bootstrapPassword", value = var.rancher_admin_password },
    { name = "hostname", value = var.rancher_hostname },
    { name = "ingress.tls.source", value = "letsEncrypt" },
    { name = "letsEncrypt.email", value = "ruslanmelnyk2005@gmail.com" },
    { name = "letsEncrypt.ingress.class", value = "traefik" },
    { name = "ingress.ingressClassName", value = "traefik" },
    { name = "agentTLSMode", value = "system-store" },
    { name = "replicas", value = "1" },
    { name = "livenessProbe.initialDelaySeconds", value = "120" },
    { name = "livenessProbe.periodSeconds", value = "30" },
    { name = "readinessProbe.initialDelaySeconds", value = "120" },
    { name = "readinessProbe.periodSeconds", value = "30" },
  ]
  wait    = true
  timeout = 600
}

resource "terraform_data" "wait_for_rancher" {
  depends_on = [helm_release.rancher]
  provisioner "local-exec" {
    command = <<-EOT
      echo "Waiting for Rancher to be ready..."
      until curl -sfk -o /dev/null "https://${var.rancher_hostname}/ping"; do
        echo "Rancher not ready yet, retrying in 10s..."
        sleep 10
      done
      echo "Rancher is up!"
    EOT
  }
}
