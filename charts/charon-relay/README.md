
Charon Relay
===========

![Version: 0.1.0](https://img.shields.io/badge/Version-0.1.0-informational?style=flat-square) ![Type: application](https://img.shields.io/badge/Type-application-informational?style=flat-square) ![AppVersion: 0.13.0](https://img.shields.io/badge/AppVersion-0.13.0-informational?style=flat-square)

Charon is an open-source Ethereum Distributed validator middleware written in golang. This chart deploys a libp2p relay server.

**Homepage:** <https://obol.tech/>

## Source Code

* <https://github.com/ObolNetwork/charon>

## Values

| Key | Type | Default                                                                                                                                                                                                                                                               | Description |
|-----|------|-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|-------------|
| affinity | object | `{}`                                                                                                                                                                                                                                                                  | Affinity for pod assignment |
| clusterSize | int | `3`                                                                                                                                                                                                                                                                   | The number of nodes in the relay cluster |
| config.autoP2pKey | string | `"true"`                                                                                                                                                                                                                                                              | Automatically create a p2pkey (secp256k1 private key used for p2p authentication and ENR) if none found in data directory. (default true) |
| config.httpAddress | string | `""`                                                                                                                                                                                                                                                                  | Listening address (ip and port) for the relay http server serving runtime ENR. (default "127.0.0.1:3640") |
| config.logFormat | string | `"json"`                                                                                                                                                                                                                                                              | Log format; console, logfmt or json (default "console") |
| config.logLevel | string | `"info"`                                                                                                                                                                                                                                                              | Log level; debug, info, warn or error (default "info") |
| config.lokiAddresses | string | `""`                                                                                                                                                                                                                                                                  | Enables sending of logfmt structured logs to these Loki log aggregation server addresses. This is in addition to normal stderr logs. |
| config.lokiService | string | `""`                                                                                                                                                                                                                                                                  | Service label sent with logs to Loki. |
| config.monitoringAddress | string | `"0.0.0.0:3620"`                                                                                                                                                                                                                                                      | Listening address (ip and port) for the monitoring API (prometheus, pprof). (default "127.0.0.1:3620") |
| config.p2pAllowlist | string | `""`                                                                                                                                                                                                                                                                  | Comma-separated list of CIDR subnets for allowing only certain peer connections. Example: 192.168.0.0/16 would permit connections to peers on your local network only. The default is to accept all connections. |
| config.p2pDenylist | string | `""`                                                                                                                                                                                                                                                                  | Comma-separated list of CIDR subnets for disallowing certain peer connections. Example: 192.168.0.0/16 would disallow connections to peers on your local network. The default is to accept all connections. |
| config.p2pDisableReuseport | string | `""`                                                                                                                                                                                                                                                                  | Disables TCP port reuse for outgoing libp2p connections. |
| config.p2pExternalHostname | string | `""`                                                                                                                                                                                                                                                                  | The DNS hostname advertised by libp2p. This may be used to advertise an external DNS. |
| config.p2pExternalIp | string | `""`                                                                                                                                                                                                                                                                  | The IP address advertised by libp2p. This may be used to advertise an external IP. |
| config.p2pMaxConnections | string | `"16384"`                                                                                                                                                                                                                                                             | Libp2p maximum number of peers that can connect to this relay. (default 16384) |
| config.p2pMaxReservatoins | string | `"512"`                                                                                                                                                                                                                                                               | Updates max circuit reservations per peer (each valid for 30min) (default 512) |
| config.p2pRelayLogLevel | string | `"info"`                                                                                                                                                                                                                                                              |  |
| config.p2pRelays | string | `""`                                                                                                                                                                                                                                                                  | Comma-separated list of libp2p relay URLs or multiaddrs. (default [https://0.relay.obol.tech/enr,http://bootnode.lb.gcp.obol.tech:3640/enr]) |
| config.p2pTcpAddress | string | `"0.0.0.0:3610"`                                                                                                                                                                                                                                                      | Comma-separated list of listening TCP addresses (ip and port) for libP2P traffic. Empty default doesn't bind to local port therefore only supports outgoing connections. |
| containerSecurityContext | object | See `values.yaml`                                                                                                                                                                                                                                                     | The security context for containers |
| fullnameOverride | string | `""`                                                                                                                                                                                                                                                                  | Provide a name to substitute for the full names of resources |
| image | object | `{"pullPolicy":"IfNotPresent","repository":"obolnetwork/charon","tag":"v0.15.0"}`                                                                                                                                                                                     | Charon image ropsitory, pull policy, and tag version |
| imagePullSecrets | list | `[]`                                                                                                                                                                                                                                                                  | Credentials to fetch images from private registry |
| livenessProbe | object | `{"enabled":true,"httpGet":{"path":"/livez"},"initialDelaySeconds":10,"periodSeconds":5}`                                                                                                                                                                             | Configure liveness probes |
| nameOverride | string | `""`                                                                                                                                                                                                                                                                  | Provide a name in place of lighthouse for `app:` labels |
| nodeSelector | object | `{}`                                                                                                                                                                                                                                                                  | Node labels for pod assignment |
| podAnnotations | object | `{}`                                                                                                                                                                                                                                                                  | Pod annotations |
| podDisruptionBudget | object | `{"enabled":true,"maxUnavailable":1,"minAvailable":0}`                                                                                                                                                                                                                | Enable pod disruption budget |
| priorityClassName | string | `""`                                                                                                                                                                                                                                                                  | Used to assign priority to pods |
| rbac | object | `{"clusterRules":[{"apiGroups":[""],"resources":["nodes"],"verbs":["get","list","watch"]}],"enabled":true,"name":"","rules":[{"apiGroups":[""],"resources":["services"],"verbs":["get","list","watch"]}]}`                                                            | RBAC configuration. |
| rbac.clusterRules | list | `[{"apiGroups":[""],"resources":["nodes"],"verbs":["get","list","watch"]}]`                                                                                                                                                                                           | Required ClusterRole rules |
| rbac.clusterRules[0] | object | `{"apiGroups":[""],"resources":["nodes"],"verbs":["get","list","watch"]}`                                                                                                                                                                                             | Required to obtain the nodes external IP |
| rbac.enabled | bool | `true`                                                                                                                                                                                                                                                                | Specifies whether RBAC resources are to be created |
| rbac.name | string | `""`                                                                                                                                                                                                                                                                  | The name of the cluster role to use. If not set and create is true, a name is generated using the fullname template |
| rbac.rules | list | `[{"apiGroups":[""],"resources":["services"],"verbs":["get","list","watch"]}]`                                                                                                                                                                                        | Required Role rules |
| rbac.rules[0] | object | `{"apiGroups":[""],"resources":["services"],"verbs":["get","list","watch"]}`                                                                                                                                                                                          | Required to get information about the serices nodePort. |
| readinessProbe | object | `{"enabled":true,"httpGet":{"path":"/readyz"},"initialDelaySeconds":5,"periodSeconds":3}`                                                                                                                                                                             | Configure readiness probes |
| resources | object | `{}`                                                                                                                                                                                                                                                                  | Pod resources limits and requests |
| securityContext | object | See `values.yaml`                                                                                                                                                                                                                                                     | The security context for pods |
| service | object | `{"ports":{"http":{"name":"http","port":3640,"protocol":"TCP","targetPort":3640},"monitoring":{"name":"monitoring","port":3620,"protocol":"TCP","targetPort":3620},"p2pTcp":{"name":"p2p-tcp","port":3610,"protocol":"TCP","targetPort":3610}},"type":"LoadBalancer"}` | Charon service ports |
| serviceAccount | object | `{"annotations":{},"enabled":true,"name":""}`                                                                                                                                                                                                                         | Service account |
| serviceAccount.annotations | object | `{}`                                                                                                                                                                                                                                                                  | Annotations to add to the service account |
| serviceAccount.enabled | bool | `true`                                                                                                                                                                                                                                                                | Specifies whether a service account should be created |
| serviceAccount.name | string | `""`                                                                                                                                                                                                                                                                  | The name of the service account to use. If not set and create is true, a name is generated using the default template |
| serviceMonitor | object | `{"annotations":{},"enabled":true,"interval":"1m","labels":{},"namespace":null,"path":"/metrics","relabelings":[],"scheme":"http","scrapeTimeout":"30s","tlsConfig":{}}`                                                                                              | Prometheus Service Monitor |
| serviceMonitor.annotations | object | `{}`                                                                                                                                                                                                                                                                  | Additional ServiceMonitor annotations |
| serviceMonitor.enabled | bool | `true`                                                                                                                                                                                                                                                                | If true, a ServiceMonitor CRD is created for a prometheus operator. https://github.com/coreos/prometheus-operator |
| serviceMonitor.interval | string | `"1m"`                                                                                                                                                                                                                                                                | ServiceMonitor scrape interval |
| serviceMonitor.labels | object | `{}`                                                                                                                                                                                                                                                                  | Additional ServiceMonitor labels |
| serviceMonitor.namespace | string | `nil`                                                                                                                                                                                                                                                                 | Alternative namespace for ServiceMonitor |
| serviceMonitor.path | string | `"/metrics"`                                                                                                                                                                                                                                                          | Path to scrape |
| serviceMonitor.relabelings | list | `[]`                                                                                                                                                                                                                                                                  | ServiceMonitor relabelings |
| serviceMonitor.scheme | string | `"http"`                                                                                                                                                                                                                                                              | ServiceMonitor scheme |
| serviceMonitor.scrapeTimeout | string | `"30s"`                                                                                                                                                                                                                                                               | ServiceMonitor scrape timeout |
| serviceMonitor.tlsConfig | object | `{}`                                                                                                                                                                                                                                                                  | ServiceMonitor TLS configuration |
| storageClassName | string | `"standard"`                                                                                                                                                                                                                                                          | Persistent volume storage class (default "standard") |
| tolerations | object | `{}`                                                                                                                                                                                                                                                                  | Tolerations for pod assignment |
| updateStrategy | string | `"RollingUpdate"`                                                                                                                                                                                                                                                     | Allows you to configure and disable automated rolling updates for containers, labels, resource request/limits, and annotations for the Pods in a StatefulSet. |

# How to use this chart

A distributed validator cluster is a docker-compose file with the following containers running:

- Single [Nethermind](https://github.com/NethermindEth/nethermind) execution layer client
- Single [Lighthouse](https://github.com/sigp/lighthouse) consensus layer client
- Six [charon](https://github.com/ObolNetwork/charon) Distributed Validator clients
- Three [Lighthouse](https://github.com/sigp/lighthouse) Validator clients
- Three [Teku](https://github.com/ConsenSys/teku) Validator Clients
- Prometheus, Grafana and Jaeger clients for monitoring this cluster.

![Distributed Validator Cluster](https://github.com/ObolNetwork/charon-distributed-validator-cluster/blob/main/DVCluster.png?raw=true)

## Add Obol's Helm Charts

```console
helm repo add obol https://obolnetwork.github.io/helm-charts
helm repo update
```
_See [helm repo](https://helm.sh/docs/helm/helm_repo/) for command documentation._

## Prerequisites
- You completed the DKG ceremony and have generated the `.charon` directory.
- The charon cluster keys are added to the Kubernetes cluster as secrets in the same namespace where the charon cluster is deployed.

### Check the creataed secrets
```console
kubeclt -n $CHARON_NODE_NAMESPACE get secrets
```
You should get list of charon secrets as the following:
- `<cluster-name>-<node-index>-validators`
- `<cluster-name>-<node-index>-charon-enr-private-key`
- `cluster-lock`

## Install the Chart
To install the chart with the release name `charon-cluster`:
```console
helm upgrade --install charon-cluster obol/charon-cluster \
  --set='clusterSize=4' \
  --set='config.beaconNodeEndpoints=<BEACON_NODES_ENDPOINTS>' \
  --create-namespace \
  --namespace $CHARON_NODE_NAMESPACE
```

## Cluster health check
Ensure the charon node is up and healthy:
```console
kubectl -n $CHARON_NODE_NAMESPACE
```

## Connect your validator client
Update the validator client to connect to charon node API endpoint.
- Teku: `--beacon-node-api-endpoint="http://CHARON_NODE_SERVICE_NAME:3600"`
You need to repeat that for each VC and charon node pair.

## Uninstall the Chart
To uninstall and delete the `charon-cluster`:
```console
helm uninstall charon-cluster
```
The command removes all the Kubernetes components associated with the chart and deletes the release.
