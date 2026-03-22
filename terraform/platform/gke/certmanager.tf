# talks to lets encrypt

resource "helm_release" "cert_manager" {
  name             = "cert-manager"
  repository       = "https://charts.jetstack.io"
  chart            = "cert-manager"
  version          = "v1.20.0"
  namespace        = "cert-manager"
  create_namespace = true
  set = [
    { name = "crds.enabled", value = "true" },
    { name = "startupapicheck.enabled", value = "true" }
  ]
  wait           = true
  wait_for_jobs  = true
  timeout        = 300
  depends_on = [helm_release.traefik]
}
