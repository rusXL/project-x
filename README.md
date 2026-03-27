# TODO
- explore other non-functional test types

## Loadtest
EKS_CTX="arn:aws:eks:us-east-1:454371013564:cluster/cluster-a"
kubectl apply -k kubernetes/eks/loadtest/ --context "$EKS_CTX"

## Security
- restrict vpc firewall rules in infra for gcp and aws

## HA
- pod resource requests, limits, hpa for api, more pods for tidb cluster
- scheduling policies to distribute components evenly across nodes
- calculate availability of the system with respect to stated SLO

