#!/bin/bash
set -e

# Install ArgoCD
kubectl create namespace argocd

kubectl apply -n argocd --server-side --force-conflicts \
  -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml

# Install TiDB CRDs and Operator
kubectl apply -f https://github.com/pingcap/tidb-operator/releases/download/v2.0.0/tidb-operator.crds.yaml --server-side

kubectl apply -f https://github.com/pingcap/tidb-operator/releases/download/v2.0.0/tidb-operator.yaml --server-side

# Bootstrap ArgoCD app of apps
kubectl apply -f kubernetes/argocd/root.yaml
