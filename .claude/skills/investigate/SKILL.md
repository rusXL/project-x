# Investigate Deployment Issue

The user has reported something broken on the cloud deployment. Your job is to diagnose the root cause and explain it clearly.

## Contexts

- **EKS (AWS)**: `arn:aws:eks:us-east-1:454371013564:cluster/cluster-a`
- **GKE (GCP)**: `gke_cloud-computing-476715_us-central1-a_cluster-g`

Use the appropriate context based on what is broken. If unclear, check both.

## Process

1. **If you are unfamiliar with the error or symptom**, use WebSearch first to understand what it typically means before running kubectl commands.

2. **Start broad, then narrow down**:
   - Check pod statuses and events in the relevant namespace
   - Check logs of affected pods
   - Check related resources (services, ingresses, configmaps, CRDs)
   - Check node pressure if pods are pending or evicted

3. **Key namespaces to know**:
   - `agama` — API (FastAPI) and Frontend (Next.js)
   - `db` — TiDB cluster (PD, TiKV, TiDB components)
   - `tidb-admin` — TiDB operator
   - `monitoring` — kube-prometheus-stack (Prometheus + Grafana)
   - `traefik` — ingress controller
   - `cattle-system` — Rancher cluster agent
   - `cattle-fleet-system` — Fleet GitOps agent

4. **Useful commands to start with**:
   ```bash
   kubectl get pods -A --context <ctx>
   kubectl get events -n <ns> --sort-by='.lastTimestamp' --context <ctx> | tail -20
   kubectl logs <pod> -n <ns> --context <ctx> --tail=50
   kubectl describe pod <pod> -n <ns> --context <ctx>
   kubectl top nodes --context <ctx>
   ```

5. **For TiDB-specific issues**, check the operator CRDs:
   ```bash
   kubectl get tidbgroups,tikvgroups,pdgroups -n db --context <eks-ctx>
   kubectl logs deployment/tidb-operator -n tidb-admin --context <eks-ctx> --tail=80
   ```

6. **For Fleet/Rancher GitOps issues**, check bundle status from the GKE management cluster:
   ```bash
   kubectl get bundles -A --context <gke-ctx>
   kubectl get bundledeployments -A --context <gke-ctx>
   ```

## Output

- State the **root cause** clearly and concisely
- Explain **why** it happened
- Suggest a **fix** with the exact commands or file changes needed
- Note any **side effects** or related issues to watch for

## Issue to investigate

$ARGUMENTS
