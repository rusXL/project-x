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


- SSR for frontend
- k8s and argocd for frontend cluster
- terraform deployments for cloud and on-premise cluster



# Install ArgoCD
kubectl create namespace argocd

kubectl apply -n argocd --server-side --force-conflicts \
  -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml


# Forward ArgoCD
kubectl port-forward svc/argocd-server -n argocd 8088:443 &

# TODO: replace with proper secret management
argocd admin initial-password -n argocd | head -1
