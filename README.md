## TODO
- test new resource definitions, number of nodes
- perform load tests until failure, see which pods fail
- target: withstand 1000 VUs and adhere to SLO

## Loadtest
EKS_CTX="arn:aws:eks:us-east-1:454371013564:cluster/cluster-a"
kubectl apply -k kubernetes/eks/loadtest/ --context "$EKS_CTX"

kubectl delete testrun api-loadtest -n agama --context "$EKS_CTX"
kubectl apply -k kubernetes/eks/loadtest/ --context "$EKS_CTX"

## HA
- pod resource requests, limits, hpa for api, more pods for tidb cluster
- scheduling policies to distribute components evenly across nodes
- calculate availability of the system with respect to stated SLO


## Future TODO
- explore other non-functional test types
- restrict vpc firewall rules in infra for gcp and aws

