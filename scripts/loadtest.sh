#!/bin/bash
set -euo pipefail

EKS_CTX="arn:aws:eks:us-east-1:454371013564:cluster/cluster-a"

if kubectl get testrun api-loadtest -n loadtest --context "$EKS_CTX" &>/dev/null; then
  kubectl delete testrun api-loadtest -n loadtest --context "$EKS_CTX"
fi

kubectl kustomize kubernetes/eks/loadtest/ | kubectl apply -f - --context "$EKS_CTX"
