#!/bin/bash
set -euo pipefail

cd "$(dirname "$0")/.."

EKS_CTX="arn:aws:eks:us-east-1:454371013564:cluster/cluster-a"
GKE_CTX="gke_cloud-computing-476715_us-central1-a_cluster-g"

# infra
cd terraform/infra
terraform init
terraform apply -auto-approve

# update LB IP in ingress manifests
LB_IP=$(terraform output -raw gke_lb_ip)
sed -i "s/\"frontend\.[0-9.]*\.nip\.io\"/\"frontend.${LB_IP}.nip.io\"/" ../../kubernetes/gke/frontend/03-ingress.yaml
sed -i "s/\"grafana\.[0-9.]*\.nip\.io\"/\"grafana.${LB_IP}.nip.io\"/" ../../kubernetes/gke/grafana/02-ingress.yaml

cd ../platform
terraform init
terraform apply -auto-approve
cd ../..

# kubeconfig
aws eks update-kubeconfig --name cluster-a --region us-east-1
gcloud container clusters get-credentials cluster-g --zone us-central1-a --project cloud-computing-476715

# tidb crds + operator
kubectl apply -f https://github.com/pingcap/tidb-operator/releases/download/v2.0.0/tidb-operator.crds.yaml \
  --server-side --context "$EKS_CTX"
kubectl apply -f https://github.com/pingcap/tidb-operator/releases/download/v2.0.0/tidb-operator.yaml \
  --server-side --context "$EKS_CTX"

# rancher agent on EKS
MANIFEST_URL=$(cd terraform/platform && terraform output -raw eks_registration_manifest)
curl -sf "$MANIFEST_URL" | kubectl apply -f - --context "$EKS_CTX"

# fleet
kubectl apply \
  -f kubernetes/eks/fleet-repo.yaml \
  -f kubernetes/gke/fleet-repo.yaml \
  --context "$GKE_CTX"

# k6 operator
curl https://raw.githubusercontent.com/grafana/k6-operator/main/bundle.yaml | kubectl apply -f - --context "$EKS_CTX"
