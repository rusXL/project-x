#!/bin/bash
set -e

# Forward API
kubectl port-forward svc/api 8000:80 -n api &
