# rancher management cluster

resource "helm_release" "rancher" {
  name             = "rancher"
  repository       = "https://releases.rancher.com/server-charts/stable"
  chart            = "rancher"
  version          = "2.13.3"
  namespace        = "cattle-system"
  create_namespace = true
  set = [
    { name = "bootstrapPassword", value = var.rancher_bootstrap_password },
    { name = "hostname", value = var.rancher_hostname },
    { name = "tls", value = "external" },
    { name = "ingress.ingressClassName", value = "traefik" },
    { name = "livenessProbe.initialDelaySeconds", value = "120" },
    { name = "livenessProbe.periodSeconds", value = "30" },
    { name = "readinessProbe.initialDelaySeconds", value = "120" },
    { name = "readinessProbe.periodSeconds", value = "30" },
    { name = "replicas", value = "1" }
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
