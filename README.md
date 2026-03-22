## Kubernetes

### Namespaces
- argocd for ArgoCD resources
- tidb-admin for tidb operator
- agama for fastapi app
- agama for nextjs app
- db for tidb-cluster

## Bootstrap
infra terraform apply
platform terraform apply

aws eks update-kubeconfig --name cluster-a --region us-east-1
gcloud container clusters get-credentials cluster-g --zone us-central1-a --project cloud-computing-476715

Install rancher agent in eks:
```bash
curl -sf "https://rancher.35.222.67.201.nip.io/v3/import/ghrsrqmbzxtp5zjrb7x8brjmr87xhvrp6xvj2tb8hcr5dsvfw5kzhn_c-wsb22.yaml" | kubectl apply -f - --context arn:aws:eks:us-east-1:454371013564:cluster/cluster-a
```
Install TiDB CRDs and Operator
```bash
kubectl apply -f https://github.com/pingcap/tidb-operator/releases/download/v2.0.0/tidb-operator.crds.yaml --server-side --context arn:aws:eks:us-east-1:454371013564:cluster/cluster-a

kubectl apply -f https://github.com/pingcap/tidb-operator/releases/download/v2.0.0/tidb-operator.yaml --server-side --context arn:aws:eks:us-east-1:454371013564:cluster/cluster-a
```


Change API IP deployment to:
```bash
kubectl get svc traefik -n traefik --context arn:aws:eks:us-east-1:454371013564:cluster/cluster-a

dig +short <hostname>
```

Update GKE LB IP in manifests (get from `terraform output gke_lb_ip` in infra/gke):
```bash
# Replace IP in:
# - kubernetes/gke/frontend/03-ingress.yaml (tls.hosts)
```

Activate Fleet (will turn up frontend, api, and tidb cluster):
```bash
kubectl apply \
  -f kubernetes/eks/fleet-repo.yaml \
  -f kubernetes/gke/fleet-repo.yaml \
  --context gke_cloud-computing-476715_us-central1-a_cluster-g
```