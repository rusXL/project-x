# rancher management cluster

resource "helm_release" "rancher" {
  name             = "rancher"
  repository       = "https://releases.rancher.com/server-charts/stable"
  chart            = "rancher"
  version          = "2.13.3"
  namespace        = "cattle-system"
  create_namespace = true

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

  depends_on = [helm_release.cert_manager]
}

resource "terraform_data" "wait_for_rancher" {
  depends_on = [helm_release.rancher]
  provisioner "local-exec" {
    command = <<-EOT
      echo "Waiting for Rancher API to be ready (with valid TLS)..."
      for i in $(seq 1 40); do
        if curl -sf -o /dev/null "https://${var.rancher_hostname}/ping" 2>/dev/null; then
          echo "Rancher API is responding with valid TLS!"
          break
        fi
        echo "Attempt $i/40: Rancher API not ready yet, retrying in 15s..."
        sleep 15
        if [ "$i" = "40" ]; then
          echo "ERROR: Timed out waiting for valid TLS on Rancher"
          exit 1
        fi
      done

      echo "Waiting for Rancher webhook to be fully operational..."
      for i in $(seq 1 40); do
        HTTP_CODE=$(curl -sk -o /dev/null -w "%%{http_code}" "https://${var.rancher_hostname}/v3/clusters" 2>/dev/null)
        if [ "$HTTP_CODE" = "200" ] || [ "$HTTP_CODE" = "401" ]; then
          echo "Rancher is fully ready (API + webhook)!"
          exit 0
        fi
        echo "Attempt $i/40: Rancher webhook not ready yet (HTTP $HTTP_CODE), retrying in 15s..."
        sleep 15
      done
      echo "ERROR: Timed out waiting for Rancher webhook to become ready"
      exit 1
    EOT
  }
}
