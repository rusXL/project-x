# Agama SLO

> **Note on latency measurement:** All latency SLIs below measure **API-side latency only** — the time
> spent in the FastAPI backend and TiDB query, as recorded by `prometheus_fastapi_instrumentator`.
> This does **not** include the full end-user round-trip (frontend rendering, cross-cloud network
> hops via GKE → VPN → EKS, or public internet). The `http_request_duration_seconds` metric does not
> carry a `status` label, so all requests (successful and failed) are included in the average.

## User Journey 1: Load main Agama dashboard

**Description:**
User visits the main Agama page to view the dashboard (`GET /items`).

---

### SLI Type: Availability

**SLI Specification:**
A request is considered *successful* if it does **not** result in an HTTP **5xx** status code.
Client errors (4xx) are expected behaviour (e.g. duplicate items, not-found) and do not count against availability.

**SLI Implementation:**
- Data source: Prometheus (via `prometheus_fastapi_instrumentator`).
- Filter: `GET /items` requests.
- Measure: ratio of successful requests (2xx/3xx) to total requests in a 10-minute window.

```promql
100 * sum(rate(http_requests_total{handler="/items", method="GET", status!~"5xx"}[10m]))
    / sum(rate(http_requests_total{handler="/items", method="GET"}[10m]))
```

**SLO:**
>= 95% of requests must return a 2xx/3xx status over **rolling 10-minute windows**.

---

### SLI Type: Latency

**SLI Implementation:**

```promql
sum(rate(http_request_duration_seconds_sum{handler="/items", method="GET"}[10m]))
  / sum(rate(http_request_duration_seconds_count{handler="/items", method="GET"}[10m]))
```

**SLO:**
Average API response time < **40ms** over 10-minute rolling windows.

---

## User Journey 2: Create an entry in Agama app

**Description:**
User submits a new entry via `POST /items`.

---

### SLI Type: Availability

**SLI Specification:**
A *successful* submission returns any non-**5xx** HTTP status.
Client errors (4xx) such as duplicate values or max-items-reached are expected and do not count against availability.

**SLI Implementation:**

```promql
100 * sum(rate(http_requests_total{handler="/items", method="POST", status!~"5xx"}[10m]))
    / sum(rate(http_requests_total{handler="/items", method="POST"}[10m]))
```

**SLO:**
>= 95% of requests must return 2xx/3xx over a **10-minute rolling window**.

---

### SLI Type: Latency

**SLI Implementation:**

```promql
sum(rate(http_request_duration_seconds_sum{handler="/items", method="POST"}[10m]))
  / sum(rate(http_request_duration_seconds_count{handler="/items", method="POST"}[10m]))
```

**SLO:**
Average API response time < **40ms** over 10-minute rolling windows.

---

## User Journey 3: Toggle an entry in Agama app

**Description:**
User toggles the state of an existing entry via `POST /items/{item_id}/toggle`.

---

### SLI Type: Availability

**SLI Specification:**
A *successful* toggle returns any non-**5xx** HTTP status.
Client errors (4xx) such as item-not-found are expected and do not count against availability.

**SLI Implementation:**

```promql
100 * sum(rate(http_requests_total{handler="/items/{item_id}/toggle", method="POST", status!~"5xx"}[10m]))
    / sum(rate(http_requests_total{handler="/items/{item_id}/toggle", method="POST"}[10m]))
```

**SLO:**
>= 95% of requests must return 2xx/3xx over a **10-minute rolling window**.

---

### SLI Type: Latency

**SLI Implementation:**

```promql
sum(rate(http_request_duration_seconds_sum{handler="/items/{item_id}/toggle", method="POST"}[10m]))
  / sum(rate(http_request_duration_seconds_count{handler="/items/{item_id}/toggle", method="POST"}[10m]))
```

**SLO:**
Average API response time < **40ms** over 10-minute rolling windows.

---

## User Journey 4: Delete an entry in Agama app

**Description:**
User deletes an existing entry via `DELETE /items/{item_id}`.

---

### SLI Type: Availability

**SLI Specification:**
A *successful* deletion returns any non-**5xx** HTTP status.
Client errors (4xx) such as item-not-found are expected and do not count against availability.

**SLI Implementation:**

```promql
100 * sum(rate(http_requests_total{handler="/items/{item_id}", method="DELETE", status!~"5xx"}[10m]))
    / sum(rate(http_requests_total{handler="/items/{item_id}", method="DELETE"}[10m]))
```

**SLO:**
>= 95% of requests must return 2xx/3xx over a **10-minute rolling window**.

---

### SLI Type: Latency

**SLI Implementation:**

```promql
sum(rate(http_request_duration_seconds_sum{handler="/items/{item_id}", method="DELETE"}[10m]))
  / sum(rate(http_request_duration_seconds_count{handler="/items/{item_id}", method="DELETE"}[10m]))
```

**SLO:**
Average API response time < **40ms** over 10-minute rolling windows.
