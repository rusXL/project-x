## TODO
- test new resource definitions, number of nodes
- perform load tests until failure, see which pods fail
- target: withstand 1000 VUs and adhere to SLO
- TIDB moniroting (https://docs.pingcap.com/tidb-in-kubernetes/dev/monitor-a-tidb-cluster/#configure-monitoring-dashboards)
- scale api pods based on latency?

## Loadtest
cd scripts && ./loadtest.sh

## HA
- pod resource requests, limits, hpa for api, more pods for tidb cluster
- scheduling policies to distribute components evenly across nodes
- calculate availability of the system with respect to stated SLO


## Future TODO
- restrict vpc firewall rules in infra for gcp and aws
