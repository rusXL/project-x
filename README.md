Namespaces:
- argocd
- tidb-admin for tidb operator
- api for fastapi app
- db for tidb-cluster

Install ArgoCD
```bash
kubectl create namespace argocd

kubectl apply -n argocd --server-side --force-conflicts -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml
```

Install TiDB CRDs
```bash
kubectl apply -f https://github.com/pingcap/tidb-operator/releases/download/v2.0.0/tidb-operator.crds.yaml --server-side
```

Bootstrap with
```bash
kubectl apply -f kubernetes/argocd/root.yaml
```

ArgoCD dashboard
```bash
kubectl port-forward svc/argocd-server -n argocd 8080:443

argocd admin initial-password -n argocd
```
TODO: password, secret management of argocd
