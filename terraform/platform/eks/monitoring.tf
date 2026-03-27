# kube-prometheus-stack

resource "helm_release" "kube_prometheus_stack" {
  name             = "kube-prometheus-stack"
  repository       = "https://prometheus-community.github.io/helm-charts"
  chart            = "kube-prometheus-stack"
  namespace        = "monitoring"
  create_namespace = true

  set = [
    { name = "prometheus.prometheusSpec.serviceMonitorSelectorNilUsesHelmValues", value = "false" },
    { name = "grafana.sidecar.dashboards.enabled", value = "true" },
    { name = "grafana.sidecar.dashboards.searchNamespace", value = "ALL" },
    { name = "alertmanager.enabled", value = "false" },
    { name = "grafana.adminPassword", value = var.grafana_admin_password },
    { name = "prometheus.prometheusSpec.enableRemoteWriteReceiver", value = "true" },
    { name = "prometheus.prometheusSpec.enableFeatures[0]", value = "native-histograms" },
  ]

  wait    = true
  timeout = 600

  depends_on = [helm_release.traefik_a]
}
