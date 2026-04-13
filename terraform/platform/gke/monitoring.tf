# kube-prometheus-stack (Prometheus + Grafana)

resource "helm_release" "kube_prometheus_stack" {
  name             = "kube-prometheus-stack"
  repository       = "https://prometheus-community.github.io/helm-charts"
  chart            = "kube-prometheus-stack"
  namespace        = "monitoring"
  create_namespace = true

  set = [
    # Prometheus
    { name = "prometheus.prometheusSpec.serviceMonitorSelectorNilUsesHelmValues", value = "false" },
    { name = "prometheus.prometheusSpec.podMonitorSelectorNilUsesHelmValues", value = "false" },
    { name = "prometheus.prometheusSpec.enableRemoteWriteReceiver", value = "true" },
    { name = "prometheus.prometheusSpec.enableFeatures[0]", value = "native-histograms" },
    { name = "prometheus.prometheusSpec.storageSpec.volumeClaimTemplate.spec.resources.requests.storage", value = "10Gi" },
    { name = "prometheus.prometheusSpec.storageSpec.volumeClaimTemplate.spec.storageClassName", value = "standard-rwo" },
    { name = "alertmanager.enabled", value = "false" },
    # Grafana
    { name = "grafana.sidecar.dashboards.enabled", value = "true" },
    { name = "grafana.sidecar.dashboards.searchNamespace", value = "ALL" },
    { name = "grafana.adminPassword", value = var.grafana_admin_password },
    { name = "grafana.resources.requests.cpu", value = "100m" },
    { name = "grafana.resources.requests.memory", value = "128Mi" },
    { name = "grafana.resources.limits.cpu", value = "500m" },
    { name = "grafana.resources.limits.memory", value = "512Mi" },
  ]

  # Additional datasource for EKS Prometheus (over VPN)
  values = [yamlencode({
    grafana = {
      additionalDataSources = [{
        name      = "EKS Prometheus"
        type      = "prometheus"
        url       = "http://prometheus.project-x"
        access    = "proxy"
        isDefault = false
      }]
    }
  })]

  wait    = true
  timeout = 600

  depends_on = [helm_release.traefik]
}
