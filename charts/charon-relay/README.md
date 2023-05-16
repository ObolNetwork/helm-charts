
Charon Relay
===========

![Version: 0.1.3](https://img.shields.io/badge/Version-0.1.3-informational?style=flat-square) ![Type: application](https://img.shields.io/badge/Type-application-informational?style=flat-square) ![AppVersion: 0.15.0](https://img.shields.io/badge/AppVersion-0.15.0-informational?style=flat-square)

Charon is an open-source Ethereum Distributed validator middleware written in golang. This chart deploys a libp2p relay server.

**Homepage:** <https://obol.tech/>

## Source Code

* <https://github.com/ObolNetwork/charon>

## Values

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| affinity | object | `{}` | Affinity for pod assignment # ref: https://kubernetes.io/docs/concepts/configuration/assign-pod-node/#affinity-and-anti-affinity # # Example: # affinity: #   podAntiAffinity: #     requiredDuringSchedulingIgnoredDuringExecution: #     - labelSelector: #         matchExpressions: #         - key: app.kubernetes.io/name #           operator: In #           values: #           - charon #       topologyKey: kubernetes.io/hostname # |
| clusterSize | int | `3` | The number of nodes in the relay cluster |
| config.autoP2pKey | string | `"true"` | Automatically create a p2pkey (secp256k1 private key used for p2p authentication and ENR) if none found in data directory. (default true) |
| config.httpAddress | string | `"0.0.0.0:3640"` | Listening address (ip and port) for the relay http server serving runtime ENR. (default "127.0.0.1:3640") |
| config.logFormat | string | `"json"` | Log format; console, logfmt or json (default "console") |
| config.logLevel | string | `"debug"` | Log level; debug, info, warn or error (default "info") |
| config.lokiAddresses | string | `""` | Enables sending of logfmt structured logs to these Loki log aggregation server addresses. This is in addition to normal stderr logs. |
| config.lokiService | string | `""` | Service label sent with logs to Loki. |
| config.monitoringAddress | string | `"0.0.0.0:3620"` | Listening address (ip and port) for the monitoring API (prometheus, pprof). (default "127.0.0.1:3620") |
| config.p2pAllowlist | string | `""` | Comma-separated list of CIDR subnets for allowing only certain peer connections. Example: 192.168.0.0/16 would permit connections to peers on your local network only. The default is to accept all connections. |
| config.p2pDenylist | string | `""` | Comma-separated list of CIDR subnets for disallowing certain peer connections. Example: 192.168.0.0/16 would disallow connections to peers on your local network. The default is to accept all connections. |
| config.p2pDisableReuseport | string | `""` | Disables TCP port reuse for outgoing libp2p connections. |
| config.p2pMaxConnections | string | `"16384"` | Libp2p maximum number of peers that can connect to this relay. (default 16384) |
| config.p2pMaxReservatoins | string | `"512"` | Updates max circuit reservations per peer (each valid for 30min) (default 512) |
| config.p2pRelayLogLevel | string | `"debug"` |  |
| config.p2pRelays | string | `""` | Comma-separated list of libp2p relay URLs or multiaddrs. (default [https://0.relay.obol.tech/enr]) |
| config.p2pTcpAddress | string | `"0.0.0.0:3610"` | Comma-separated list of listening TCP addresses (ip and port) for libP2P traffic. Empty default doesn't bind to local port therefore only supports outgoing connections. |
| containerSecurityContext | object | See `values.yaml` | The security context for containers |
| fullnameOverride | string | `""` | Provide a name to substitute for the full names of resources |
| image | object | `{"pullPolicy":"IfNotPresent","repository":"obolnetwork/charon","tag":"v0.15.0"}` | Charon image ropsitory, pull policy, and tag version |
| imagePullSecrets | list | `[]` | Credentials to fetch images from private registry # ref: https://kubernetes.io/docs/tasks/configure-pod-container/pull-image-private-registry/ |
| initContainerImage | string | `"bitnami/kubectl:latest"` | Init container image |
| livenessProbe | object | `{"enabled":true,"httpGet":{"path":"/livez"},"initialDelaySeconds":10,"periodSeconds":5}` | Configure liveness probes # ref: https://kubernetes.io/docs/tasks/configure-pod-container/configure-liveness-readiness-startup-probes/ |
| nameOverride | string | `""` | Provide a name in place of lighthouse for `app:` labels |
| nodeSelector | object | `{}` | Node labels for pod assignment # ref: https://kubernetes.io/docs/user-guide/node-selection/ |
| podAnnotations | object | `{}` | Pod annotations |
| podDisruptionBudget | object | `{"enabled":true,"maxUnavailable":1,"minAvailable":0}` | Enable pod disruption budget # ref: https://kubernetes.io/docs/tasks/run-application/configure-pdb |
| priorityClassName | string | `""` | Used to assign priority to pods # ref: https://kubernetes.io/docs/concepts/configuration/pod-priority-preemption/ |
| rbac | object | `{"clusterRules":[{"apiGroups":[""],"resources":["nodes"],"verbs":["get","list","watch"]}],"enabled":true,"name":"","rules":[{"apiGroups":[""],"resources":["services"],"verbs":["get","list","watch"]}]}` | RBAC configuration. # ref: https://kubernetes.io/docs/reference/access-authn-authz/rbac/ |
| rbac.clusterRules | list | `[{"apiGroups":[""],"resources":["nodes"],"verbs":["get","list","watch"]}]` | Required ClusterRole rules |
| rbac.clusterRules[0] | object | `{"apiGroups":[""],"resources":["nodes"],"verbs":["get","list","watch"]}` | Required to obtain the nodes external IP |
| rbac.enabled | bool | `true` | Specifies whether RBAC resources are to be created |
| rbac.name | string | `""` | The name of the cluster role to use. If not set and create is true, a name is generated using the fullname template |
| rbac.rules | list | `[{"apiGroups":[""],"resources":["services"],"verbs":["get","list","watch"]}]` | Required Role rules |
| rbac.rules[0] | object | `{"apiGroups":[""],"resources":["services"],"verbs":["get","list","watch"]}` | Required to get information about the serices nodePort. |
| readinessProbe | object | `{"enabled":true,"httpGet":{"path":"/readyz"},"initialDelaySeconds":5,"periodSeconds":3}` | Configure readiness probes # ref: https://kubernetes.io/docs/tasks/configure-pod-container/configure-liveness-readiness-startup-probes/ |
| resources | object | `{}` | Pod resources limits and requests |
| securityContext | object | See `values.yaml` | The security context for pods |
| service | object | `{"ports":{"http":{"name":"relay-http","port":3640,"protocol":"TCP","targetPort":3640},"monitoring":{"name":"monitoring","port":3620,"protocol":"TCP","targetPort":3620},"p2pTcp":{"name":"p2p-tcp","port":3610,"protocol":"TCP","targetPort":3610}},"type":"LoadBalancer"}` | Charon service ports |
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
| storageClassName | string | `"standard"` | Persistent volume storage class (default "standard") |
| tolerations | object | `{}` | Tolerations for pod assignment # ref: https://kubernetes.io/docs/concepts/configuration/taint-and-toleration/ |
| updateStrategy | string | `"RollingUpdate"` | Allows you to configure and disable automated rolling updates for containers, labels, resource request/limits, and annotations for the Pods in a StatefulSet. |

# How to use this chart

A charon public relay composed of the following infrastructure containers:
- HAProxy (reverse proxy) in front of the charon relay nodes
- The haproxy uses the `cluster-name` to establish a sticky session between the charon cluster nodes and the relay server
- One or more charon instances started in relay mode and deployed as Kubernetes statefulsets.

## Add Obol's Helm Charts

```console
helm repo add obol https://obolnetwork.github.io/helm-charts
helm repo update
```
_See [helm repo](https://helm.sh/docs/helm/helm_repo/) for command documentation._

## Prerequisites
- A valid domain (i.e obol.tech)
- An operational Kubernetes cluster (This chart supports GKE only)
- Kubernetes add-ons: nginx-ingress, external-dns, and cert-manager.

## Install the Chart
To install the chart with the release name `charon-relay`:
```console
helm upgrade --install charon-relay obol/charon-relay \
  --set='clusterSize=3' \
  --create-namespace \
  --namespace charon-relay
```

## Cluster health check
Ensure the charon node is up and healthy:
```console
kubectl -n charon-relay
```

## Uninstall the Chart
To uninstall and delete the `charon-relay`:
```console
helm uninstall charon-relay
```
The command removes all the Kubernetes components associated with the chart and deletes the release.
