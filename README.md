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

## Open
```bash
chmod +x open.sh
./open.sh
```

## API

Opens at :8080

## ArgoCD

Looks for changes in internal apps on GitHub, syncs the cluster with the remote.

Opens at :8088

## Frontend

Run locally
```bash
npm run dev
```
