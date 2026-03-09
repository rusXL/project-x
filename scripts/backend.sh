#!/bin/bash
set -e

# Install TiDB CRDs and Operator
kubectl apply -f https://github.com/pingcap/tidb-operator/releases/download/v2.0.0/tidb-operator.crds.yaml --server-side

kubectl apply -f https://github.com/pingcap/tidb-operator/releases/download/v2.0.0/tidb-operator.yaml --server-side

# TiDB Cluster
kubectl apply -f kubernetes/apps/tidb

# API
kubectl apply -f kubernetes/apps/api
