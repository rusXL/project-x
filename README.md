# TODO

## Test
- api load test (kubectl apply -k kubernetes/eks/loadtest/)
- explore other non-functional test types

## Security
- restrict vpc firewall rules in infra for gcp and aws

## HA
- pod resource requests, limits, hpa for api, more pods for tidb cluster
- scheduling policies to distribute components evenly across nodes
- calculate availability of the system with respect to stated SLO
