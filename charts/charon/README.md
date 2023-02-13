
Charon
===========

![Version: 0.2.1](https://img.shields.io/badge/Version-0.2.1-informational?style=flat-square) ![Type: application](https://img.shields.io/badge/Type-application-informational?style=flat-square) ![AppVersion: 0.13.0](https://img.shields.io/badge/AppVersion-0.13.0-informational?style=flat-square)

Charon is an open-source Ethereum Distributed validator middleware written in golang.

**Homepage:** <https://obol.tech/>

## Source Code

* <https://github.com/ObolNetwork/charon>

## Values

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| affinity | object | `{}` | Affinity for pod assignment |
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
| config.monitoringAddress | string | `"0.0.0.0:3620"` | Listening address (ip and port) for the monitoring API (prometheus, pprof). (default "127.0.0.1:3620") |
| config.noVerify | bool | `false` | Disables cluster definition and lock file verification. |
| config.p2pAllowlist | string | `""` | Comma-separated list of CIDR subnets for allowing only certain peer connections. Example: 192.168.0.0/16 would permit connections to peers on your local network only. The default is to accept all connections. |
| config.p2pDenylist | string | `""` | Comma-separated list of CIDR subnets for disallowing certain peer connections. Example: 192.168.0.0/16 would disallow connections to peers on your local network. The default is to accept all connections. |
| config.p2pDisableReuseport | string | `""` | Disables TCP port reuse for outgoing libp2p connections. |
| config.p2pExternalHostname | string | `""` | The DNS hostname advertised by libp2p. This may be used to advertise an external DNS. |
| config.p2pExternalIp | string | `""` | The IP address advertised by libp2p. This may be used to advertise an external IP. |
| config.p2pRelays | string | `"https://0.relay.obol.tech/enr,http://bootnode.lb.gcp.obol.tech:3640/enr"` | Comma-separated list of libp2p relay URLs or multiaddrs. (default [https://0.relay.obol.tech/enr,http://bootnode.lb.gcp.obol.tech:3640/enr]) |
| config.p2pTcpAddress | string | `"0.0.0.0:3610"` | Comma-separated list of listening TCP addresses (ip and port) for libP2P traffic. Empty default doesn't bind to local port therefore only supports outgoing connections. |
| config.privateKeyFile | string | `"/charon/charon-enr-private-key/charon-enr-private-key"` | The path to the charon enr private key file. (default ".charon/charon-enr-private-key") |
| config.simnetBeaconMock | string | `""` | Enables an internal mock beacon node for running a simnet. |
| config.simnetValidatorKeysDir | string | `""` | The directory containing the simnet validator key shares. (default ".charon/validator_keys") |
| config.simnetValidatorMock | string | `""` | Enables an internal mock validator client when running a simnet. Requires simnet-beacon-mock. |
| config.syntheticBlockProposals | string | `""` | Enables additional synthetic block proposal duties. Used for testing of rare duties. |
| config.validatorApiAddress | string | `"0.0.0.0:3600"` | Listening address (ip and port) for validator-facing traffic proxying the beacon-node API. (default "127.0.0.1:3600") |
| containerSecurityContext | object | See `values.yaml` | The security context for containers |
| fullnameOverride | string | `""` | Provide a name to substitute for the full names of resources |
| image | object | `{"pullPolicy":"IfNotPresent","repository":"obolnetwork/charon","tag":"v0.13.0"}` | Charon image ropsitory, pull policy, and tag version |
| imagePullSecrets | list | `[]` | Credentials to fetch images from private registry |
| livenessProbe | object | `{"enabled":true,"httpGet":{"path":"/livez"},"initialDelaySeconds":10,"periodSeconds":5}` | Configure liveness probes |
| nameOverride | string | `""` | Provide a name in place of lighthouse for `app:` labels |
| nodeSelector | object | `{}` | Node labels for pod assignment |
| podAnnotations | object | `{}` | Pod annotations |
| podDisruptionBudget | object | `{"enabled":false,"maxUnavailable":1}` | Enable and configure pod disruption budget |
| priorityClassName | string | `""` | Used to assign priority to pods |
| rbac | object | `{"clusterRules":[{"apiGroups":[""],"resources":["nodes"],"verbs":["get","list","watch"]}],"enabled":true,"name":"","rules":[{"apiGroups":[""],"resources":["services"],"verbs":["get","list","watch"]}]}` | RBAC configuration. |
| rbac.clusterRules | list | `[{"apiGroups":[""],"resources":["nodes"],"verbs":["get","list","watch"]}]` | Required ClusterRole rules |
| rbac.clusterRules[0] | object | `{"apiGroups":[""],"resources":["nodes"],"verbs":["get","list","watch"]}` | Required to obtain the nodes external IP |
| rbac.enabled | bool | `true` | Specifies whether RBAC resources are to be created |
| rbac.name | string | `""` | The name of the cluster role to use. If not set and create is true, a name is generated using the fullname template |
| rbac.rules | list | `[{"apiGroups":[""],"resources":["services"],"verbs":["get","list","watch"]}]` | Required Role rules |
| rbac.rules[0] | object | `{"apiGroups":[""],"resources":["services"],"verbs":["get","list","watch"]}` | Required to get information about the serices nodePort. |
| readinessProbe | object | `{"enabled":true,"httpGet":{"path":"/readyz"},"initialDelaySeconds":5,"periodSeconds":3}` | Configure readiness probes |
| resources | object | `{}` | Pod resources limits and requests |
| secrets | object | `{"clusterlock":"cluster-lock","enrPrivateKey":"charon-enr-private-key","validatorKeys":"validator-keys"}` | Kubernetes secrets names |
| secrets.clusterlock | string | `"cluster-lock"` | charon cluster lock |
| secrets.enrPrivateKey | string | `"charon-enr-private-key"` | charon enr private key |
| secrets.validatorKeys | string | `"validator-keys"` | validators keys |
| securityContext | object | See `values.yaml` | The security context for pods |
| service | object | `{"ports":{"monitoring":{"name":"monitoring","port":3620,"protocol":"TCP","targetPort":3620},"p2pTcp":{"name":"p2p-tcp","port":3610,"protocol":"TCP","targetPort":3610},"validatorApi":{"name":"validator-api","port":3600,"protocol":"TCP","targetPort":3600}},"type":"ClusterIP"}` | Charon service ports |
| serviceAccount | object | `{"annotations":{},"enabled":true,"name":""}` | Service account |
| serviceAccount.annotations | object | `{}` | Annotations to add to the service account |
| serviceAccount.enabled | bool | `true` | Specifies whether a service account should be created |
| serviceAccount.name | string | `""` | The name of the service account to use. If not set and create is true, a name is generated using the default template |
| serviceMonitor | object | `{"annotations":{},"enabled":true,"interval":"1m","labels":{},"namespace":null,"path":"/metrics","relabelings":[],"scheme":"http","scrapeTimeout":"30s","tlsConfig":{}}` | Prometheus Service Monitor |
| serviceMonitor.annotations | object | `{}` | Additional ServiceMonitor annotations |
| serviceMonitor.enabled | bool | `true` | If true, a ServiceMonitor CRD is created for a prometheus operator. https://github.com/coreos/prometheus-operator |
| serviceMonitor.interval | string | `"1m"` | ServiceMonitor scrape interval |
| serviceMonitor.labels | object | `{}` | Additional ServiceMonitor labels |
| serviceMonitor.namespace | string | `nil` | Alternative namespace for ServiceMonitor |
| serviceMonitor.path | string | `"/metrics"` | Path to scrape |
| serviceMonitor.relabelings | list | `[]` | ServiceMonitor relabelings |
| serviceMonitor.scheme | string | `"http"` | ServiceMonitor scheme |
| serviceMonitor.scrapeTimeout | string | `"30s"` | ServiceMonitor scrape timeout |
| serviceMonitor.tlsConfig | object | `{}` | ServiceMonitor TLS configuration |
| tolerations | object | `{}` | Tolerations for pod assignment |

# How to use this chart

A distributed validator node is a machine running:

- An Ethereum Execution client
- An Ethereum Consensus client
- An Ethereum Distributed Validator client [This chart]
- An Ethereum Validator client

![Distributed Validator Node](https://github.com/ObolNetwork/charon-distributed-validator-node/blob/main/DVNode.png?raw=true)

## Add Obol's Helm Charts
```console
helm repo add obol https://obolnetwork.github.io/helm-charts
helm repo update
```
_See [helm repo](https://helm.sh/docs/helm/helm_repo/) for command documentation._

## Prerequisites
- You completed the DKG ceremony and have generated the `.charon` directory.
- The charon cluster keys are added to your Kubernetes cluster as secrets to the same namespace where the charon node is deployed.

### Example: How to create the k8s secrets from a `.charon` directory:
```console
cat << 'EOF' >> create-k8s-secrets.sh
files=""
CHARON_NODE_NAMESPACE=charon-node
for secret in ./.charon/validator_keys/*; do
    files="$files --from-file=./.charon/validator_keys/$(basename $secret)"
done
kubectl -n $CHARON_NODE_NAMESPACE create secret generic validator-keys $files --dry-run=client -o yaml | kubectl apply -f -
kubectl -n $CHARON_NODE_NAMESPACE create secret generic charon-enr-private-key --from-file=charon-enr-private-key=./.charon/charon-enr-private-key --dry-run=client -o yaml | kubectl apply -f -
kubectl -n $CHARON_NODE_NAMESPACE create secret generic cluster-lock --from-file=cluster-lock.json=./.charon/cluster-lock.json --dry-run=client -o yaml | kubectl apply -f -
EOF
chmod +x create-k8s-secrets.sh && ./create-k8s-secrets.sh
```

### Check the secrets are created
```console
kubeclt -n $CHARON_NODE_NAMESPACE get secrets
```
You should get list of charon secrets as the following:
- `validator-keys`
- `charon-enr-private-key`
- `cluster-lock`

## Install the chart
```console
helm upgrade --install charon-node obol/charon \
  --set='config.beaconNodeEndpoints=<BEACON_NODES_ENDPOINTS>' \
  --create-namespace \
  --namespace $CHARON_NODE_NAMESPACE
```

## Connect your validator client
Ensure the charon node is up and healthy:
```console
kubectl -n $CHARON_NODE_NAMESPACE
```
Update the validator client to connect to charon node API endpoint.
For example:
- Teku: `--beacon-node-api-endpoint="http://CHARON_NODE_SERVICE_NAME:3600"`

## Uninstall the chart
To uninstall and delete the `charon-node`:
```console
helm uninstall charon-node
```
The command removes all the Kubernetes components associated with the chart and deletes the release.
