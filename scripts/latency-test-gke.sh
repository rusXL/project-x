#!/bin/bash
set -euo pipefail

GKE_CTX="gke_cloud-computing-476715_us-east4-a_cluster-g"

if kubectl get testrun latency-test -n load-test --context "$GKE_CTX" &>/dev/null; then
  kubectl delete testrun latency-test -n load-test --context "$GKE_CTX"
fi

kubectl kustomize kubernetes/gke/latency-test/ | kubectl apply -f - --context "$GKE_CTX"
