For future:

- Secret management for api config, argodb dashboard, later grafana dashboard
- HPA for api
- Configure scheduling policies to distribute components evenly across nodes
- Redis
- Monitoring, Alerting with Prometheus + Grafana



- terraform, ingress for frontend and backend
- Rancher fleet cd
- ssl for load balancer



URGENT: fix eks volume claims



infra terraform apply
platform terraform apply


aws eks update-kubeconfig --name cluster-a --region us-east-1
gcloud container clusters get-credentials cluster-g --zone us-central1-a --project cloud-computing-476715

Install rancher agent in eks:
```bash
curl -sfk "https://rancher.35.222.67.201.nip.io/v3/import/xxcmzqzz4sbc9szsvnl9lrvxtkl9tpjqnf9xf559qj44cp6nssvvvw_c-wmbmn.yaml" | kubectl apply -f - --context arn:aws:eks:us-east-1:454371013564:cluster/cluster-a
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

Configure gp3 storage
```bash
kubectl apply -f kubernetes/eks/storage/gp3.yaml \
  --context arn:aws:eks:us-east-1:454371013564:cluster/cluster-a
```

Activate Fleet (will turn up frontend, api, and tidb cluster):
```bash
kubectl apply \
  -f kubernetes/eks/fleet-repo.yaml \
  -f kubernetes/gke/fleet-repo.yaml \
  --context gke_cloud-computing-476715_us-central1-a_cluster-g
```






TODO: private dns for rancher ui, backend internal lb
