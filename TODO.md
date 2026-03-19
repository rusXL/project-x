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








aws eks update-kubeconfig --name cluster-a --region us-east-1

curl -sfk https://rancher.34.10.170.110.nip.io/v3/import/wgxnxwvchstzq7kcpfmtrqsnpmc4k2f8x8tv9wrk9srrmwc74n5wf2_c-92qvr.yaml | \
  kubectl apply -f - --context arn:aws:eks:us-east-1:454371013564:cluster/cluster-a


gcloud container clusters get-credentials cluster-g --zone us-central1-a --project cloud-computing-476715

kubectl apply -f kubernetes/eks/fleet-repo.yaml --context gke_cloud-computing-476715_us-central1-a_cluster-g
kubectl apply -f kubernetes/gke/fleet-repo.yaml --context gke_cloud-computing-476715_us-central1-a_cluster-g






private dns for rancher ui, backend internal lb
