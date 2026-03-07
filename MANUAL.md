(without argo cd)

kubectl apply -f https://github.com/pingcap/tidb-operator/releases/download/v2.0.0/tidb-operator.crds.yaml --server-side

kubectl apply -f https://github.com/pingcap/tidb-operator/releases/download/v2.0.0/tidb-operator.yaml --server-side
or
helm install tidb-operator oci://ghcr.io/pingcap/charts/tidb-operator --version v2.0.0 --namespace tidb-admin --create-namespace


kubectl apply -f kubernetes/apps/tidb --server-side

kubectl apply -f kubernetes/apps/api


kubectl port-forward svc/api 8080:80 -n api
