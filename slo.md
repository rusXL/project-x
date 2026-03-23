# Agama SLO

## User Journey 1: Load main Agama dashboard

**Description:**
User visits the main Agama page to view the dashboard.
We monitor both **availability** (success rate of page loads) and **latency** (speed of responses).

---

### SLI Type: Availability

**SLI Specification:**
A request is considered *successful* if it results in an HTTP **2xx** or **3xx** status code.

**SLI Implementation:**
- Data source: Prometheus (via `prometheus_fastapi_instrumentator`).
- Filter: `GET /items` requests.
- Measure: ratio of successful requests (2xx/3xx) to total requests in a 10-minute window.

```promql
100 * sum(rate(http_requests_total{handler="/items", method="GET", status=~"2xx|3xx"}[10m]))
    / sum(rate(http_requests_total{handler="/items", method="GET"}[10m]))
```

**SLO:**
>= 95% of main page requests must return a 2xx/3xx status over **rolling 10-minute windows**.

---

### SLI Type: Latency

**SLI Specification:**
A request is considered *fast* if the average API response time is **< 40ms**.
This measures only the API-side latency (time spent in the FastAPI backend + TiDB query), not the full end-user round-trip which also includes the frontend, cross-cloud network hops (GKE → VPN → EKS), and public internet.

**SLI Implementation:**
- Data source: Prometheus (via `prometheus_fastapi_instrumentator`).
- The `http_request_duration_seconds` metric does not carry a `status` label, so all requests (successful and failed) are included in the average.

```promql
sum(rate(http_request_duration_seconds_sum{handler="/items", method="GET"}[10m]))
  / sum(rate(http_request_duration_seconds_count{handler="/items", method="GET"}[10m]))
```

**SLO:**
Average API response time < **40ms** over 10-minute rolling windows.

---

## User Journey 2: Create an entry in Agama app

**Description:**
User submits a new entry (via `POST /items`) to store data in the Agama app.
We monitor how often submissions succeed and how long they take to complete.

---

### SLI Type: Availability

**SLI Specification:**
A *successful* submission returns a **2xx** or **3xx** HTTP status.

**SLI Implementation:**

```promql
100 * sum(rate(http_requests_total{handler="/items", method="POST", status=~"2xx|3xx"}[10m]))
    / sum(rate(http_requests_total{handler="/items", method="POST"}[10m]))
```

**SLO:**
>= 95% of create-entry requests must return 2xx/3xx over a 10-minute rolling window.

---

### SLI Type: Latency

**SLI Specification:**
An entry creation is *fast* if the average API response time is **< 40ms**.
This measures only the API-side latency (time spent in the FastAPI backend + TiDB query), not the full end-user round-trip which also includes the frontend, cross-cloud network hops (GKE → VPN → EKS), and public internet.

**SLI Implementation:**
- Data source: Prometheus (via `prometheus_fastapi_instrumentator`).
- The `http_request_duration_seconds` metric does not carry a `status` label, so all requests (successful and failed) are included in the average.

```promql
sum(rate(http_request_duration_seconds_sum{handler="/items", method="POST"}[10m]))
  / sum(rate(http_request_duration_seconds_count{handler="/items", method="POST"}[10m]))
```

**SLO:**
Average API response time < **40ms** over 10-minute rolling windows.
