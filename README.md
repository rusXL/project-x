## Kubernetes

### Namespaces
- argocd for ArgoCD resources
- tidb-admin for tidb operator
- agama for fastapi app
- agama for nextjs app
- db for tidb-cluster

## Bootstrap
```bash
terraform apply -target=helm_release.rancher # rancher
terraform apply # fleet
```
