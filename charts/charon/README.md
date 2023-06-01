
Charon
===========

![Version: 0.2.6](https://img.shields.io/badge/Version-0.2.6-informational?style=flat-square) ![Type: application](https://img.shields.io/badge/Type-application-informational?style=flat-square) ![AppVersion: 0.15.0](https://img.shields.io/badge/AppVersion-0.15.0-informational?style=flat-square)

Charon is an open-source Ethereum Distributed validator middleware written in golang.

**Homepage:** <https://obol.tech/>

## Source Code

* <https://github.com/ObolNetwork/charon>

## Values

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| affinity | object | `{}` | Affinity for pod assignment # ref: https://kubernetes.io/docs/concepts/configuration/assign-pod-node/#affinity-and-anti-affinity # # Example: # affinity: #   podAntiAffinity: #     requiredDuringSchedulingIgnoredDuringExecution: #     - labelSelector: #         matchExpressions: #         - key: app.kubernetes.io/name #           operator: In #           values: #           - charon #       topologyKey: kubernetes.io/hostname # |
| config.LockFile | string | `"/charon/cluster-lock/cluster-lock.json"` | The path to the cluster lock file defining distributed validator cluster. (default ".charon/cluster-lock.json") |
| config.beaconNodeEndpoints | string | `""` | Comma separated list of one or more beacon node endpoint URLs. |
| config.builderApi | string | `""` | Enables the builder api. Will only produce builder blocks. Builder API must also be enabled on the validator client. Beacon node must be connected to a builder-relay to access the builder network. |
| config.featureSet | string | `"stable"` | Minimum feature set to enable by default: alpha, beta, or stable. Warning: modify at own risk. (default "stable") |
| config.featureSetDisable | string | `""` | Comma-separated list of features to disable, overriding the default minimum feature set. |
| config.featureSetEnable | string | `""` | Comma-separated list of features to enable, overriding the default minimum feature set. |
| config.jaegerAddress | string | `"jaeger:6831"` | Listening address for jaeger tracing. |
| config.jaegerService | string | `"charon"` | Service name used for jaeger tracing. (default "charon") |
| config.logFormat | string | `"json"` | Log format; console, logfmt or json (default "console") |
| config.logLevel | string | `"info"` | Log level; debug, info, warn or error (default "info") |
| config.lokiAddresses | string | `""` | Enables sending of logfmt structured logs to these Loki log aggregation server addresses. This is in addition to normal stderr logs. |
| config.lokiService | string | `"charon"` | Service label sent with logs to Loki. (default "charon") |
| config.monitoringAddress | string | `"0.0.0.0"` | Listening address (ip and port) for the monitoring API (prometheus, pprof). (default "127.0.0.1:3620") |
| config.noVerify | bool | `false` | Disables cluster definition and lock file verification. |
| config.p2pAllowlist | string | `""` | Comma-separated list of CIDR subnets for allowing only certain peer connections. Example: 192.168.0.0/16 would permit connections to peers on your local network only. The default is to accept all connections. |
| config.p2pDenylist | string | `""` | Comma-separated list of CIDR subnets for disallowing certain peer connections. Example: 192.168.0.0/16 would disallow connections to peers on your local network. The default is to accept all connections. |
| config.p2pDisableReuseport | string | `""` | Disables TCP port reuse for outgoing libp2p connections. |
| config.p2pExternalHostname | string | `""` | The DNS hostname advertised by libp2p. This may be used to advertise an external DNS. |
| config.p2pExternalIp | string | `""` | The IP address advertised by libp2p. This may be used to advertise an external IP. |
| config.p2pRelays | string | `"https://0.relay.obol.tech/enr"` | Comma-separated list of libp2p relay URLs or multiaddrs. (default [https://0.relay.obol.tech/enr]) |
| config.p2pTcpAddress | string | `"0.0.0.0"` | Comma-separated list of listening TCP addresses (ip and port) for libP2P traffic. Empty default doesn't bind to local port therefore only supports outgoing connections. |
| config.privateKeyFile | string | `"/charon/charon-enr-private-key/charon-enr-private-key"` | The path to the charon enr private key file. (default ".charon/charon-enr-private-key") |
| config.simnetBeaconMock | string | `""` | Enables an internal mock beacon node for running a simnet. |
| config.simnetValidatorKeysDir | string | `""` | The directory containing the simnet validator key shares. (default ".charon/validator_keys") |
| config.simnetValidatorMock | string | `""` | Enables an internal mock validator client when running a simnet. Requires simnet-beacon-mock. |
| config.syntheticBlockProposals | string | `""` | Enables additional synthetic block proposal duties. Used for testing of rare duties. |
| config.validatorApiAddress | string | `"0.0.0.0"` | Listening address (ip and port) for validator-facing traffic proxying the beacon-node API. (default "127.0.0.1:3600") |
| containerSecurityContext | object | See `values.yaml` | The security context for containers |
| extraContainers | list | `[]` | Additional containers |
| extraEnv | list | `[]` | Additional env variables |
| extraPorts | list | `[]` | Additional ports. Useful when using extraContainers |
| extraVolumeMounts | list | `[]` | Additional volume mounts |
| extraVolumes | list | `[]` | Additional volumes |
| fullnameOverride | string | `""` | Provide a name to substitute for the full names of resources |
| httpPort | int | `3600` | HTTP Port |
| image | object | `{"pullPolicy":"IfNotPresent","repository":"obolnetwork/charon","tag":"v0.15.0"}` | Charon image ropsitory, pull policy, and tag version |
| imagePullSecrets | list | `[]` | Credentials to fetch images from private registry # ref: https://kubernetes.io/docs/tasks/configure-pod-container/pull-image-private-registry/ |
| initContainers | list | `[]` | Additional init containers |
| jaegerPort | int | `6831` | Jaeger Port |
| livenessProbe | object | `{"httpGet":{"path":"/livez","port":"monitoring"},"initialDelaySeconds":60,"periodSeconds":120}` | Configure liveness probes |
| monitoringPort | int | `3620` | Monitoring Port |
| nameOverride | string | `""` | Provide a name in place of lighthouse for `app:` labels |
| nodeSelector | object | `{}` | Node labels for pod assignment # ref: https://kubernetes.io/docs/user-guide/node-selection/ |
| p2pPort | int | `3610` | Engine Port (Auth Port) |
| podAnnotations | object | `{}` | Pod annotations |
| podDisruptionBudget | object | `{"enabled":false,"maxUnavailable":1}` | Enable and configure pod disruption budget # ref: https://kubernetes.io/docs/tasks/run-application/configure-pdb |
| priorityClassName | string | `""` | Used to assign priority to pods # ref: https://kubernetes.io/docs/concepts/configuration/pod-priority-preemption/ |
| prometheus.enabled | bool | `false` |  |
| prometheus.image | string | `"prom/prometheus"` |  |
| prometheus.resources | object | `{}` |  |
| prometheus.tag | string | `"v2.30.0"` |  |
| rbac | object | `{"clusterRules":[{"apiGroups":[""],"resources":["nodes"],"verbs":["get","list","watch"]}],"enabled":true,"name":"","rules":[{"apiGroups":[""],"resources":["services"],"verbs":["get","list","watch"]}]}` | RBAC configuration. # ref: https://kubernetes.io/docs/reference/access-authn-authz/rbac/ |
| rbac.clusterRules | list | `[{"apiGroups":[""],"resources":["nodes"],"verbs":["get","list","watch"]}]` | Required ClusterRole rules |
| rbac.clusterRules[0] | object | `{"apiGroups":[""],"resources":["nodes"],"verbs":["get","list","watch"]}` | Required to obtain the nodes external IP |
| rbac.enabled | bool | `true` | Specifies whether RBAC resources are to be created |
| rbac.name | string | `""` | The name of the cluster role to use. If not set and create is true, a name is generated using the fullname template |
| rbac.rules | list | `[{"apiGroups":[""],"resources":["services"],"verbs":["get","list","watch"]}]` | Required Role rules |
| rbac.rules[0] | object | `{"apiGroups":[""],"resources":["services"],"verbs":["get","list","watch"]}` | Required to get information about the serices nodePort. |
| readinessProbe | object | `{"httpGet":{"path":"/readyz","port":"monitoring"},"initialDelaySeconds":10,"periodSeconds":10}` | Configure readiness probes |
| resources | object | `{}` | Pod resources limits and requests |
| secrets | object | `{"clusterlock":"cluster-lock","enrPrivateKey":"charon-enr-private-key","validatorKeys":"validator-keys"}` | Kubernetes secrets names |
| secrets.clusterlock | string | `"cluster-lock"` | charon cluster lock |
| secrets.enrPrivateKey | string | `"charon-enr-private-key"` | charon enr private key |
| secrets.validatorKeys | string | `"validator-keys"` | validators keys |
| securityContext | object | See `values.yaml` | The security context for pods |
| service.type | string | `"ClusterIP"` | Service type |
| serviceAccount | object | `{"annotations":{},"enabled":true,"name":""}` | Service account # ref: https://kubernetes.io/docs/tasks/configure-pod-container/configure-service-account/ |
| serviceAccount.annotations | object | `{}` | Annotations to add to the service account |
| serviceAccount.enabled | bool | `true` | Specifies whether a service account should be created |
| serviceAccount.name | string | `""` | The name of the service account to use. If not set and create is true, a name is generated using the default template |
| serviceMonitor | object | `{"annotations":{},"enabled":false,"interval":"1m","labels":{},"namespace":null,"path":"/metrics","relabelings":[],"scheme":"http","scrapeTimeout":"30s","tlsConfig":{}}` | Prometheus Service Monitor # ref: https://github.com/coreos/prometheus-operator |
| serviceMonitor.annotations | object | `{}` | Additional ServiceMonitor annotations |
| serviceMonitor.enabled | bool | `false` | If true, a ServiceMonitor CRD is created for a prometheus operator. https://github.com/coreos/prometheus-operator |
| serviceMonitor.interval | string | `"1m"` | ServiceMonitor scrape interval |
| serviceMonitor.labels | object | `{}` | Additional ServiceMonitor labels |
| serviceMonitor.namespace | string | `nil` | Alternative namespace for ServiceMonitor |
| serviceMonitor.path | string | `"/metrics"` | Path to scrape |
| serviceMonitor.relabelings | list | `[]` | ServiceMonitor relabelings |
| serviceMonitor.scheme | string | `"http"` | ServiceMonitor scheme |
| serviceMonitor.scrapeTimeout | string | `"30s"` | ServiceMonitor scrape timeout |
| serviceMonitor.tlsConfig | object | `{}` | ServiceMonitor TLS configuration |
| tolerations | object | `{}` | Tolerations for pod assignment # ref: https://kubernetes.io/docs/concepts/configuration/taint-and-toleration/ |

# How to use this chart

A distributed validator node is a machine running:

- An Ethereum Execution client
- An Ethereum Consensus client
- An Ethereum Distributed Validator client [This chart]
- An Ethereum Validator client

![Distributed Validator Node](https://github.com/ObolNetwork/charon-distributed-validator-node/blob/main/DVNode.png?raw=true)

## Prerequisites
You have the followin charon node artifacts created as k8s secrets:
- `validator-keys`
- `charon-enr-private-key`
- `cluster-lock`

## Add Obol's Helm Charts
```console
helm repo add obol https://obolnetwork.github.io/helm-charts
helm repo update
```
_See [helm repo](https://helm.sh/docs/helm/helm_repo/) for command documentation._

## Install the chart
```console
helm upgrade --install charon-node obol/charon \
  --set='config.beaconNodeEndpoints=<BEACON_NODES_ENDPOINTS>' \
  --create-namespace \
  --namespace $CHARON_NODE_NAMESPACE
```

## Connect the validator client
- Update the validator client to connect to charon node API endpoint instead of the beacon node endpoint `--beacon-node-api-endpoint="http://CHARON_NODE_SERVICE_NAME:3600"`
- Mount `validator-keys` k8s secrets to the validator client validator folder.

## Uninstall the chart
To uninstall and delete the `charon-node`:
```console
helm uninstall charon-node
```
The command removes all the Kubernetes components associated with the chart and deletes the release.
