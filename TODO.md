- Secret management for api config, argodb dashboard, later grafana dashboard
- HPA for api
- Configure scheduling policies to distribute components evenly across nodes
- Kong Ingress Controller in front of api - acts as prod load balancer and api gateway
- Redis
- Monitoring, Alerting with Prometheus + Grafana

- Calculate resources and nodes needed
- Ansible, Terraform deployment

- load balancer SSL cert?
- DNS?

- terraform, ingress for frontend and backend
- Rancher fleet cd
- ssl for load balancer

kubectl get certificate -n cattle-system --context gke_cloud-computing-476715_us-central1-a_cluster-g


fix eks volume claims



infra terraform apply
platform terraform apply


aws eks update-kubeconfig --name cluster-a --region us-east-1
gcloud container clusters get-credentials cluster-g --zone us-central1-a --project cloud-computing-476715

Install rancher agent in eks:
```bash
curl -sfk "https://rancher.136.119.91.49.nip.io/v3/import/ltdf49v7546qg9ghmwmxd24kq579qqc2cjn4sgr9rhssr7sw8hkn6k_c-nv6rs.yaml" | kubectl apply -f - --context arn:aws:eks:us-east-1:454371013564:cluster/cluster-a
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


Activate Fleet (will turn up frontend, api, and tidb cluster):
```bash
kubectl apply \
  -f kubernetes/eks/fleet-repo.yaml \
  -f kubernetes/gke/fleet-repo.yaml \
  --context gke_cloud-computing-476715_us-central1-a_cluster-g
```






private dns for rancher ui, backend internal lb
