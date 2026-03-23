## Bootstrap
Launch infra:
```bash
cd terraform/infra terraform apply
cd ../platform terraform apply
```

Update ref to EKS and GKE clusters:
```bash
aws eks update-kubeconfig --name cluster-a --region us-east-1
gcloud container clusters get-credentials cluster-g --zone us-central1-a --project cloud-computing-476715
```

Install Rancher agent in EKS:
```bash
curl -sf "https://rancher.34.27.42.13.nip.io/v3/import/6gdgqj74dtm9gn4dj2crcb96g6d7s6zm482vptn7tp4l7vzmxwxfv5_c-lhnds.yaml" | kubectl apply -f - --context arn:aws:eks:us-east-1:454371013564:cluster/cluster-a
```

Install TiDB CRDs and Operator
```bash
kubectl apply -f https://github.com/pingcap/tidb-operator/releases/download/v2.0.0/tidb-operator.crds.yaml --server-side --context arn:aws:eks:us-east-1:454371013564:cluster/cluster-a

kubectl apply -f https://github.com/pingcap/tidb-operator/releases/download/v2.0.0/tidb-operator.yaml --server-side --context arn:aws:eks:us-east-1:454371013564:cluster/cluster-a
```

Replace IP in:
```
kubernetes/gke/frontend/03-ingress.yaml (tls.hosts)
```

Activate Fleet (will turn up frontend, api, and tidb cluster):
```bash
cd ../../ && kubectl apply \
  -f kubernetes/eks/fleet-repo.yaml \
  -f kubernetes/gke/fleet-repo.yaml \
  --context gke_cloud-computing-476715_us-central1-a_cluster-g
```

## Destroy
Launch infra:
```bash
cd terraform/platform terraform destroy
cd ../infra terraform destroy
```
