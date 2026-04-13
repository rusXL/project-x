#!/bin/bash
set -euo pipefail

EKS_CTX="arn:aws:eks:us-east-1:454371013564:cluster/cluster-a"

if kubectl get testrun latency-test -n load-test --context "$EKS_CTX" &>/dev/null; then
  kubectl delete testrun latency-test -n load-test --context "$EKS_CTX"
fi

kubectl kustomize kubernetes/eks/latency-test/ | kubectl apply -f - --context "$EKS_CTX"
