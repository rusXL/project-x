#!/bin/bash
set -euo pipefail

EKS_CTX="arn:aws:eks:us-east-1:454371013564:cluster/cluster-a"

if kubectl get testrun api-load-test -n load-test --context "$EKS_CTX" &>/dev/null; then
  kubectl delete testrun api-load-test -n load-test --context "$EKS_CTX"
fi

kubectl kustomize kubernetes/eks/load-test/ | kubectl apply -f - --context "$EKS_CTX"
