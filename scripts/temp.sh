#!/bin/bash
cd terraform/infra
echo "=== GKE ==="
echo "gke_endpoint = \"$(terraform output -raw gke_endpoint)\""
echo "gke_ca_cert  = \"$(terraform output -raw gke_ca_cert)\""
echo "gke_token    = \"$(terraform output -raw gke_token)\""
echo "gke_lb_ip    = \"$(terraform output -raw gke_lb_ip)\""
echo ""
echo "=== EKS ==="
echo "eks_endpoint = \"$(terraform output -raw eks_endpoint)\""
echo "eks_ca_cert  = \"$(terraform output -raw eks_ca_cert)\""
echo "eks_token    = \"$(terraform output -raw eks_token)\""
