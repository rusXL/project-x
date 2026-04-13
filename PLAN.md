# Plan: Cross-Cluster Latency Testing + Observability Refactor

## Context

Current setup has all monitoring (Prometheus + Grafana) on EKS, with k6 load tests only running intra-cluster. Two goals:

1. **Observability refactor**: GKE is the management cluster (Rancher lives there), so Grafana should too. Each cluster gets its own Prometheus. Grafana on GKE queries both.
2. **Latency baseline testing**: Run a lightweight, steady-state k6 test from both EKS and GKE to measure pure VPN/network overhead by comparing latency. Load testing (high VU ramp) stays EKS-only since it measures system capacity, not network overhead.

## Architecture (before → after)

```
BEFORE:                              AFTER:
EKS: Prometheus + Grafana            EKS: Prometheus only
GKE: Grafana proxy (ExternalName)    GKE: Prometheus + Grafana (queries both)

Tests:                               Tests:
EKS: load test (1000 VU ramp)        EKS: load test (1000 VU ramp) — system capacity
                                     EKS: latency baseline (50 VU steady) ─┐ compare
                                     GKE: latency baseline (50 VU steady) ─┘ VPN overhead
```

---

## Part A: Observability Refactor

### A1. Deploy kube-prometheus-stack on GKE (Prometheus + Grafana)

**`terraform/platform/gke/monitoring.tf`** (new) — Deploy kube-prometheus-stack with:
- Prometheus: remote write receiver enabled, native histograms, `standard-rwo` storage
- Grafana: sidecar dashboards enabled, admin password from variable
- Additional datasource for EKS Prometheus: `http://prometheus.project-x` (reachable over VPN)

```hcl
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

  depends_on = [helm_release.traefik]
}
```

**`terraform/platform/gke/variables.tf`** — Add `grafana_admin_password` variable.

### A2. Disable Grafana on EKS

**`terraform/platform/eks/monitoring.tf`** — Add `grafana.enabled = false` to disable Grafana from the EKS kube-prometheus-stack. Keep Prometheus and everything else unchanged.

### A3. Expose EKS Prometheus via Traefik (for GKE Grafana to query)

**`terraform/platform/eks/dns.tf`** — Replace `grafana.project-x` record with `prometheus.project-x`:
```hcl
resource "aws_route53_record" "prometheus" {
  zone_id = var.aws_zone_id
  name    = "prometheus.project-x"
  type    = "CNAME"
  ttl     = 60
  records = [data.kubernetes_service.traefik.status[0].load_balancer[0].ingress[0].hostname]
}
```

**`kubernetes/eks/monitoring/02-ingress.yaml`** — Replace Grafana IngressRoute with Prometheus IngressRoute:
```yaml
apiVersion: traefik.io/v1alpha1
kind: IngressRoute
metadata:
  name: prometheus
  namespace: monitoring
spec:
  entryPoints:
    - web
  routes:
    - match: Host(`prometheus.project-x`)
      kind: Rule
      services:
        - name: kube-prometheus-stack-prometheus
          port: 9090
```

### A4. Move dashboards from EKS to GKE

Dashboards need to live where Grafana is.

**`kubernetes/gke/monitoring/`** (new directory):
- `dashboards/k6-dashboard.json` — moved from `kubernetes/eks/monitoring/dashboards/`
- `dashboards/api-dashboard.json` — moved from `kubernetes/eks/monitoring/dashboards/`
- `dashboards/tidb-cluster.json` — moved from `kubernetes/eks/monitoring/dashboards/`
- `dashboards/kustomization.yaml` — moved from `kubernetes/eks/monitoring/dashboards/` (same content)
- `kustomization.yaml` — references dashboards subdirectory

**`kubernetes/eks/monitoring/kustomization.yaml`** — Remove `dashboards` from resources (no Grafana on EKS to consume them).

### A5. Replace Grafana proxy with local Grafana ingress on GKE

**`kubernetes/gke/grafana/`** — Replace contents:

**`01-ingress.yaml`** (rewrite, replaces both old files) — Traefik IngressRoute pointing to local Grafana in monitoring namespace:
```yaml
apiVersion: traefik.io/v1alpha1
kind: IngressRoute
metadata:
  name: grafana
  namespace: monitoring
spec:
  entryPoints:
    - websecure
  routes:
    - match: Host(`grafana.34.48.110.4.nip.io`)
      kind: Rule
      services:
        - name: kube-prometheus-stack-grafana
          port: 80
  tls:
    certResolver: letsencrypt-prod
```

**Delete** `01-externalname-service.yaml` and `02-ingress.yaml` (no longer proxying to EKS).

Switching from standard Ingress (in `agama` namespace) to Traefik IngressRoute (in `monitoring` namespace) avoids cross-namespace backend issues.

### A6. Update Fleet repos

**`kubernetes/gke/fleet-repo.yaml`** — Add monitoring path:
```yaml
paths:
  - kubernetes/gke/frontend
  - kubernetes/gke/grafana
  - kubernetes/gke/monitoring
```

**`kubernetes/eks/fleet-repo.yaml`** — No change needed.

### A7. Update bootstrap.sh

**`scripts/bootstrap.sh`** — Remove the `sed` command for `grafana.*.nip.io` in GKE ingress (file is being rewritten as IngressRoute, hostname will be handled differently).

---

## Part B: Load Testing & Latency Baseline Testing

### B1. Load test — EKS only (existing, minor cleanup)

The existing load test stays EKS-only. It measures system capacity under stress (10→1000 VU ramp). No changes to existing files:
- `kubernetes/eks/loadtest/api.test.js` — unchanged
- `kubernetes/eks/loadtest/testrun.yaml` — unchanged
- `scripts/loadtest.sh` — unchanged

### B2. Create latency baseline k6 script

**`kubernetes/eks/latency-test/latency.test.js`** (new) — Lightweight, steady-state test:
```javascript
import http from "k6/http";
import { check, sleep } from "k6";

const BASE_URL = __ENV.BASE_URL || "http://api.agama.svc.cluster.local";
const CLUSTER = __ENV.CLUSTER || "eks";

export const options = {
  tags: { cluster: CLUSTER },
  stages: [
    { duration: "30s", target: 50 },   // ramp up
    { duration: "10m", target: 50 },   // steady state
    { duration: "30s", target: 0 },    // ramp down
  ],
  thresholds: {},
};

export default function () {
  const value = `latency-${CLUSTER}-${__VU}-${__ITER}-${Date.now()}`;
  const createRes = http.post(
    `${BASE_URL}/items`,
    JSON.stringify({ value }),
    { headers: { "Content-Type": "application/json" } },
  );
  check(createRes, { "create 201": (r) => r.status === 201 });

  const item = createRes.json();

  if (__ITER % 10 === 0) {
    const listRes = http.get(`${BASE_URL}/items`);
    check(listRes, { "list 200": (r) => r.status === 200 });
  }

  if (item && item.id) {
    const toggleRes = http.post(`${BASE_URL}/items/${item.id}/toggle`);
    check(toggleRes, { "toggle 200": (r) => r.status === 200 });

    const deleteRes = http.del(`${BASE_URL}/items/${item.id}`);
    check(deleteRes, { "delete 204": (r) => r.status === 204 });
  }

  sleep(1);
}
```

Key differences from load test: constant 50 VUs for 10 min (clean signal), `cluster` tag for identification, configurable `BASE_URL`.

### B3. Create EKS latency test manifests

**`kubernetes/eks/latency-test/`** (new directory):
- `namespace.yaml` — reuses `loadtest` namespace
- `testrun.yaml` — TestRun with `CLUSTER=eks`, `BASE_URL=http://api.agama.svc.cluster.local`, remote write to local Prometheus
- `kustomization.yaml` — ConfigMap from `latency.test.js`

### B4. Create GKE latency test manifests

**`kubernetes/gke/latency-test/`** (new directory):
- `namespace.yaml` — `loadtest` namespace
- `latency.test.js` — Copy of the same script
- `testrun.yaml` — TestRun with:
  - `CLUSTER=gke`
  - `BASE_URL=http://api.project-x` (API over VPN)
  - `K6_PROMETHEUS_RW_SERVER_URL=http://kube-prometheus-stack-prometheus.monitoring.svc.cluster.local:9090/api/v1/write` (local GKE Prometheus)
- `kustomization.yaml`

### B5. Install k6-operator on GKE

**`scripts/bootstrap.sh`** — Add at the end:
```bash
curl https://raw.githubusercontent.com/grafana/k6-operator/main/bundle.yaml | kubectl apply -f - --context "$GKE_CTX"
```

### B6. Create latency test scripts (separate per cluster)

Running both simultaneously would double backend load and skew results. Separate scripts so each runs independently.

**`scripts/latency-test-eks.sh`** (new):
```bash
#!/bin/bash
set -euo pipefail
EKS_CTX="arn:aws:eks:us-east-1:454371013564:cluster/cluster-a"
if kubectl get testrun latency-test -n loadtest --context "$EKS_CTX" &>/dev/null; then
  kubectl delete testrun latency-test -n loadtest --context "$EKS_CTX"
fi
kubectl kustomize kubernetes/eks/latency-test/ | kubectl apply -f - --context "$EKS_CTX"
```

**`scripts/latency-test-gke.sh`** (new):
```bash
#!/bin/bash
set -euo pipefail
GKE_CTX="gke_cloud-computing-476715_us-east4-a_cluster-g"
if kubectl get testrun latency-test -n loadtest --context "$GKE_CTX" &>/dev/null; then
  kubectl delete testrun latency-test -n loadtest --context "$GKE_CTX"
fi
kubectl kustomize kubernetes/gke/latency-test/ | kubectl apply -f - --context "$GKE_CTX"
```

Run one, wait for it to finish, then run the other. Compare results in Grafana.

### B7. Existing k6 dashboard — no changes needed

The existing k6 dashboard has a `DS_PROMETHEUS` variable. To compare latency:
- Select **GKE Prometheus** → see cross-cluster (VPN) latency from GKE k6 pods
- Select **EKS Prometheus** → see intra-cluster latency from EKS k6 pods

The `cluster` tag is also available for any future filtering needs.

---

## File Summary

| Action | File | Part |
|--------|------|------|
| Create | `terraform/platform/gke/monitoring.tf` | A1 |
| Modify | `terraform/platform/gke/variables.tf` | A1 |
| Modify | `terraform/platform/eks/monitoring.tf` | A2 |
| Modify | `terraform/platform/eks/dns.tf` | A3 |
| Modify | `kubernetes/eks/monitoring/02-ingress.yaml` | A3 |
| Create | `kubernetes/gke/monitoring/kustomization.yaml` | A4 |
| Create | `kubernetes/gke/monitoring/dashboards/kustomization.yaml` | A4 |
| Move | `kubernetes/eks/monitoring/dashboards/*.json` → `kubernetes/gke/monitoring/dashboards/` | A4 |
| Modify | `kubernetes/eks/monitoring/kustomization.yaml` | A4 |
| Rewrite | `kubernetes/gke/grafana/01-ingress.yaml` | A5 |
| Delete | `kubernetes/gke/grafana/01-externalname-service.yaml` | A5 |
| Delete | `kubernetes/gke/grafana/02-ingress.yaml` | A5 |
| Modify | `kubernetes/gke/fleet-repo.yaml` | A6 |
| Modify | `scripts/bootstrap.sh` | A7, B5 |
| Create | `kubernetes/eks/latency-test/latency.test.js` | B2 |
| Create | `kubernetes/eks/latency-test/namespace.yaml` | B3 |
| Create | `kubernetes/eks/latency-test/testrun.yaml` | B3 |
| Create | `kubernetes/eks/latency-test/kustomization.yaml` | B3 |
| Create | `kubernetes/gke/latency-test/latency.test.js` | B4 |
| Create | `kubernetes/gke/latency-test/namespace.yaml` | B4 |
| Create | `kubernetes/gke/latency-test/testrun.yaml` | B4 |
| Create | `kubernetes/gke/latency-test/kustomization.yaml` | B4 |
| Create | `scripts/latency-test-eks.sh` | B6 |
| Create | `scripts/latency-test-gke.sh` | B6 |

## Verification

1. `terraform apply` in `terraform/platform` — creates GKE monitoring stack + `prometheus.project-x` DNS
2. Verify Fleet syncs: dashboards appear on GKE Grafana, EKS Prometheus IngressRoute active
3. From GKE pod: `curl http://prometheus.project-x/-/ready` returns 200
4. Open Grafana on GKE (`grafana.{LB_IP}.nip.io`), confirm both datasources work
5. Run `scripts/loadtest.sh` — EKS load test works as before
6. Run `scripts/latency-test-eks.sh`, wait for completion (~11 min)
7. Run `scripts/latency-test-gke.sh`, wait for completion (~11 min)
8. In k6 dashboard: switch `DS_PROMETHEUS` between GKE and EKS Prometheus to compare latency numbers
