#!/bin/bash
set -e

# Forward API
kubectl port-forward svc/api 8080:80 -n api &

# Forward ArgoCD
kubectl port-forward svc/argocd-server -n argocd 8088:443 &

# TODO: replace with proper secret management
argocd admin initial-password -n argocd | head -1

wait