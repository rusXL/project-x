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
      echo "Waiting for Rancher to be ready (with valid TLS)..."
      for i in $(seq 1 60); do
        if curl -sf -o /dev/null "https://${var.rancher_hostname}/ping" 2>/dev/null; then
          echo "Rancher is up with valid TLS!"
          exit 0
        fi
        echo "Attempt $i/60: Rancher not ready yet (cert may still be provisioning), retrying in 15s..."
        sleep 15
      done
      echo "ERROR: Timed out waiting for Rancher with valid TLS certificate"
      exit 1
    EOT
  }
}
