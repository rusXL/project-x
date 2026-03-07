Namespaces:
- argocd
- tidb-admin for tidb operator
- api for fastapi app
- db for tidb-cluster

Bootstrap with
```bash
kubectl apply -f kubernetes/argocd/root.yaml
```

ArgoCD dashboard
```bash
kubectl port-forward svc/argocd-server -n argocd 8080:443
```
```bash
argocd admin initial-password -n argocd
```
TODO: password, secret management of argocd
