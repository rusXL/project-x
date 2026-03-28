# kube-prometheus-stack

resource "helm_release" "kube_prometheus_stack" {
  name             = "kube-prometheus-stack"
  repository       = "https://prometheus-community.github.io/helm-charts"
  chart            = "kube-prometheus-stack"
  namespace        = "monitoring"
  create_namespace = true

  set = [
    { name = "prometheus.prometheusSpec.serviceMonitorSelectorNilUsesHelmValues", value = "false" },
    { name = "prometheus.prometheusSpec.podMonitorSelectorNilUsesHelmValues", value = "false" },
    { name = "grafana.sidecar.dashboards.enabled", value = "true" },
    { name = "grafana.sidecar.dashboards.searchNamespace", value = "ALL" },
    { name = "alertmanager.enabled", value = "false" },
    { name = "grafana.adminPassword", value = var.grafana_admin_password },
    { name = "prometheus.prometheusSpec.enableRemoteWriteReceiver", value = "true" },
    { name = "prometheus.prometheusSpec.enableFeatures[0]", value = "native-histograms" },
    { name = "prometheus.prometheusSpec.resources.requests.cpu", value = "250m" },
    { name = "prometheus.prometheusSpec.resources.requests.memory", value = "1Gi" },
    { name = "prometheus.prometheusSpec.resources.limits.cpu", value = "1" },
    { name = "prometheus.prometheusSpec.resources.limits.memory", value = "2Gi" },
    { name = "prometheus.prometheusSpec.storageSpec.volumeClaimTemplate.spec.resources.requests.storage", value = "10Gi" },
    { name = "prometheus.prometheusSpec.storageSpec.volumeClaimTemplate.spec.storageClassName", value = "gp3" },
    { name = "grafana.resources.requests.cpu", value = "100m" },
    { name = "grafana.resources.requests.memory", value = "128Mi" },
    { name = "grafana.resources.limits.cpu", value = "500m" },
    { name = "grafana.resources.limits.memory", value = "512Mi" },
  ]

  wait    = true
  timeout = 600

  depends_on = [helm_release.traefik_a]
}
