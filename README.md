## Kubernetes

### Namespaces
- argocd for ArgoCD resources
- tidb-admin for tidb operator
- api for fastapi app
- db for tidb-cluster

## Bootstrap
```bash
chmod +x bootstrap.sh
./bootstrap.sh
```

## API

Port forward to access with
```bash
kubectl port-forward svc/api 8080:80 -n api
```

## ArgoCD

Looks for changes in internal apps on GitHub, syncs the cluster with the remote.

Dashboard
```bash
kubectl port-forward svc/argocd-server -n argocd 8088:443
argocd admin initial-password -n argocd # TODO: password, secret management of argocd
```
