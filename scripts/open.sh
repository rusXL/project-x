#!/bin/bash
set -e

# # Forward API
# kubectl port-forward svc/api 8000:80 -n agama &

# Forward Frontend
kubectl port-forward svc/frontend 3000:80 -n agama &

wait
