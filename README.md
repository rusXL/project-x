# TODO

## Security
- kubernetes secret management for tidb connection
- restrict vpc firewall rules in infra for gcp and aws
- consider moving to private subnets with a single nat for internet access

## Monitoring
- prometheus + grafana helm charts
- rancher
- sla for dashboard load

## HA
- pod resource requests, limits, hpa for api, more pods for tidb cluster
- scheduling policies to distribute components evenly across nodes
