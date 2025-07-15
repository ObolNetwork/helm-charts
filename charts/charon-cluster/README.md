
Charon Cluster
===========

![Version: 0.3.6](https://img.shields.io/badge/Version-0.3.6-informational?style=flat-square) ![Type: application](https://img.shields.io/badge/Type-application-informational?style=flat-square) ![AppVersion: 1.5.1](https://img.shields.io/badge/AppVersion-1.5.1-informational?style=flat-square)

Charon is an open-source Ethereum Distributed validator middleware written in golang. This chart deploys a full Charon cluster.

**Homepage:** <https://obol.tech/>

## Source Code

* <https://github.com/ObolNetwork/charon>

## Values

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| affinity | object | `{}` | Affinity for pod assignment # ref: https://kubernetes.io/docs/concepts/configuration/assign-pod-node/#affinity-and-anti-affinity # # Example: # affinity: #   podAntiAffinity: #     requiredDuringSchedulingIgnoredDuringExecution: #     - labelSelector: #         matchExpressions: #         - key: app.kubernetes.io/name #           operator: In #           values: #           - charon #       topologyKey: kubernetes.io/hostname # |
| centralMonitoring | object | `{"enabled":false,"promEndpoint":"https://vm.monitoring.gcp.obol.tech/write","token":""}` | Central Monitoring |
| centralMonitoring.enabled | bool | `false` | Specifies whether central monitoring should be enabled |
| centralMonitoring.promEndpoint | string | `"https://vm.monitoring.gcp.obol.tech/write"` | https endpoint to obol central prometheus  |
| centralMonitoring.token | string | `""` | The authentication token to the central prometheus |
| clusterSize | int | `4` | The number of charon nodes in the cluster. Minimum is 4 |
| clusterThreshold | int | `3` | Cluster threshold required for signature reconstruction. Defaults to ceil(n*2/3) if zero. Warning, non-default values decrease security. |
| config.LockFile | string | `"/charon/cluster-lock.json"` | The path to the cluster lock file defining distributed validator cluster. (default ".charon/cluster-lock.json") |
| config.beaconNodeEndpoints | string | `""` | Comma separated list of one or more beacon node endpoint URLs. |
| config.builderApi | string | `""` | Enables the builder api. Will only produce builder blocks. Builder API must also be enabled on the validator client. Beacon node must be connected to a builder-relay to access the builder network. |
| config.directConnectionEnabled | string | `"true"` | If enabled, it will set p2pExternalHostname value to the pod name and enable direct connection between cluster nodes |
| config.featureSet | string | `"stable"` | Minimum feature set to enable by default: alpha, beta, or stable. Warning: modify at own risk. (default "stable") |
| config.featureSetDisable | string | `""` | Comma-separated list of features to disable, overriding the default minimum feature set. |
| config.featureSetEnable | string | `""` | Comma-separated list of features to enable, overriding the default minimum feature set. |
| config.jaegerAddress | string | `"jaeger:6831"` | Listening address for jaeger tracing. |
| config.jaegerService | string | `""` | Service name used for jaeger tracing. |
| config.logFormat | string | `"json"` | Log format; console, logfmt or json (default "console") |
| config.logLevel | string | `"info"` | Log level; debug, info, warn or error (default "info") |
| config.lokiAddresses | string | `""` | Enables sending of logfmt structured logs to these Loki log aggregation server addresses. This is in addition to normal stderr logs. |
| config.lokiService | string | `""` | Service label sent with logs to Loki. |
| config.monitoringAddress | string | `"0.0.0.0:3620"` | Listening address (ip and port) for the monitoring API (prometheus, pprof). (default "127.0.0.1:3620") |
| config.noVerify | bool | `false` | Disables cluster definition and lock file verification. |
| config.p2pAllowlist | string | `""` | Comma-separated list of CIDR subnets for allowing only certain peer connections. Example: 192.168.0.0/16 would permit connections to peers on your local network only. The default is to accept all connections. |
| config.p2pDenylist | string | `""` | Comma-separated list of CIDR subnets for disallowing certain peer connections. Example: 192.168.0.0/16 would disallow connections to peers on your local network. The default is to accept all connections. |
| config.p2pDisableReuseport | string | `""` | Disables TCP port reuse for outgoing libp2p connections. |
| config.p2pExternalHostname | string | `""` | The DNS hostname advertised by libp2p. This may be used to advertise an external DNS. |
| config.p2pExternalIp | string | `""` | The IP address advertised by libp2p. This may be used to advertise an external IP. |
| config.p2pRelays | string | `""` | Comma-separated list of libp2p relay URLs or multiaddrs. (default [https://0.relay.obol.tech/enr]) |
| config.p2pTcpAddress | string | `"0.0.0.0:3610"` | Comma-separated list of listening TCP addresses (ip and port) for libP2P traffic. Empty default doesn't bind to local port therefore only supports outgoing connections. |
| config.simnetBeaconMock | string | `""` | Enables an internal mock beacon node for running a simnet. |
| config.simnetValidatorKeysDir | string | `""` | The directory containing the simnet validator key shares. (default ".charon/validator_keys") |
| config.simnetValidatorMock | string | `""` | Enables an internal mock validator client when running a simnet. Requires simnet-beacon-mock. |
| config.syntheticBlockProposals | string | `""` | Enables additional synthetic block proposal duties. Used for testing of rare duties. |
| config.validatorApiAddress | string | `"0.0.0.0:3600"` | Listening address (ip and port) for validator-facing traffic proxying the beacon-node API. (default "127.0.0.1:3600") |
| containerSecurityContext | object | See `values.yaml` | The security context for containers |
| fullnameOverride | string | `""` | Provide a name to substitute for the full names of resources |
| image | object | `{"pullPolicy":"IfNotPresent","repository":"obolnetwork/charon","tag":"v1.5.1"}` | Charon image repository, pull policy, and tag version |
| imagePullSecrets | list | `[]` | Credentials to fetch images from private registry # ref: https://kubernetes.io/docs/tasks/configure-pod-container/pull-image-private-registry/ |
| livenessProbe | object | `{"enabled":false,"httpGet":{"path":"/livez"},"initialDelaySeconds":10,"periodSeconds":5}` | Configure liveness probes # ref: https://kubernetes.io/docs/tasks/configure-pod-container/configure-liveness-readiness-startup-probes/ |
| nameOverride | string | `""` | Provide a name in place of lighthouse for `app:` labels |
| nodeSelector | object | `{}` | Node labels for pod assignment # ref: https://kubernetes.io/docs/user-guide/node-selection/ |
| podAnnotations | object | `{}` | Pod annotations |
| podDisruptionBudget | object | `{"enabled":true,"minAvailable":""}` | Enable pod disruption budget # ref: https://kubernetes.io/docs/tasks/run-application/configure-pdb |
| priorityClassName | string | `""` | Used to assign priority to pods # ref: https://kubernetes.io/docs/concepts/configuration/pod-priority-preemption/ |
| rbac | object | `{"clusterRules":[{"apiGroups":[""],"resources":["nodes"],"verbs":["get","list","watch"]}],"enabled":true,"name":"","rules":[{"apiGroups":[""],"resources":["services"],"verbs":["get","list","watch"]}]}` | RBAC configuration. # ref: https://kubernetes.io/docs/reference/access-authn-authz/rbac/ |
| rbac.clusterRules | list | `[{"apiGroups":[""],"resources":["nodes"],"verbs":["get","list","watch"]}]` | Required ClusterRole rules |
| rbac.clusterRules[0] | object | `{"apiGroups":[""],"resources":["nodes"],"verbs":["get","list","watch"]}` | Required to obtain the nodes external IP |
| rbac.enabled | bool | `true` | Specifies whether RBAC resources are to be created |
| rbac.name | string | `""` | The name of the cluster role to use. If not set and create is true, a name is generated using the fullname template |
| rbac.rules | list | `[{"apiGroups":[""],"resources":["services"],"verbs":["get","list","watch"]}]` | Required Role rules |
| rbac.rules[0] | object | `{"apiGroups":[""],"resources":["services"],"verbs":["get","list","watch"]}` | Required to get information about the serices nodePort. |
| readinessProbe | object | `{"enabled":false,"httpGet":{"path":"/readyz"},"initialDelaySeconds":5,"periodSeconds":3}` | Configure readiness probes # ref: https://kubernetes.io/docs/tasks/configure-pod-container/configure-liveness-readiness-startup-probes/ |
| resources | object | `{}` | Pod resources limits and requests |
| secrets | object | `{"clusterlock":"cluster-lock","enrPrivateKey":"charon-enr-private-key","validatorKeys":"validators"}` | Kubernetes secrets names |
| secrets.clusterlock | string | `"cluster-lock"` | charon cluster lock |
| secrets.enrPrivateKey | string | `"charon-enr-private-key"` | charon enr private key |
| secrets.validatorKeys | string | `"validators"` | validators keys |
| securityContext | object | See `values.yaml` | The security context for pods |
| service | object | `{"clusterIP":"None","ports":{"monitoring":{"name":"monitoring","port":3620,"protocol":"TCP","targetPort":3620},"p2pTcp":{"name":"p2p-tcp","port":3610,"protocol":"TCP","targetPort":3610},"validatorApi":{"name":"validator-api","port":3600,"protocol":"TCP","targetPort":3600}}}` | Charon service ports |
| service.clusterIP | string | `"None"` | Headless service to create DNS for each statefulset instance |
| serviceAccount | object | `{"annotations":{},"enabled":true,"name":""}` | Service account # ref: https://kubernetes.io/docs/tasks/configure-pod-container/configure-service-account/ |
| serviceAccount.annotations | object | `{}` | Annotations to add to the service account |
| serviceAccount.enabled | bool | `true` | Specifies whether a service account should be created |
| serviceAccount.name | string | `""` | The name of the service account to use. If not set and create is true, a name is generated using the default template |
| serviceMonitor | object | `{"annotations":{},"enabled":true,"interval":"1m","labels":{},"namespace":null,"path":"/metrics","relabelings":[],"scheme":"http","scrapeTimeout":"30s","tlsConfig":{}}` | Prometheus Service Monitor # ref: https://github.com/coreos/prometheus-operator |
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
| tolerations | object | `{}` | Tolerations for pod assignment # ref: https://kubernetes.io/docs/concepts/configuration/taint-and-toleration/ |
| updateStrategy | string | `"RollingUpdate"` | allows you to configure and disable automated rolling updates for containers, labels, resource request/limits, and annotations for the Pods in a StatefulSet. |

# How to use this chart

A distributed validator cluster is composed of the following containers:

- Single execution layer client
- Single consensus layer client
- Number of Distributed Validator clients [This chart]
- Number of Validator clients
- Prometheus, Grafana and Jaeger clients for monitoring this cluster.

![Distributed Validator Cluster](https://github.com/ObolNetwork/charon-distributed-validator-cluster/blob/main/DVCluster.png?raw=true)

## Prerequisites

This chart deploys a single distributed validator pod. You have two options for providing the required artifacts:

### Option 1: Pre-existing DKG artifacts (skip DKG process)

If you already have DKG artifacts from a ceremony, you can provide them to skip the DKG process entirely.

#### Example 1a: From a multi-node cluster output (./cluster/ structure)

When you've run DKG for multiple nodes and have a `./cluster/` directory:

```
./cluster/
├── node0/
│   ├── charon-enr-private-key
│   ├── cluster-lock.json
│   └── validator_keys/
│       ├── keystore-0.json
│       └── keystore-0.txt
├── node1/
│   ├── charon-enr-private-key
│   ├── cluster-lock.json
│   └── validator_keys/
│       ├── keystore-0.json
│       └── keystore-0.txt
└── ...
```

To deploy node0 using this chart:
```console
# Create ENR private key secret
kubectl create secret generic charon-enr-private-key --from-file=cluster/node0/charon-enr-private-key

# Create the cluster lock ConfigMap (same for all nodes)
kubectl create configmap my-cluster-lock --from-file=cluster/node0/cluster-lock.json

# Install the chart, referencing your ConfigMap
helm install my-dv-pod obol/dv-pod \
  --set configMaps.clusterlock=my-cluster-lock
```

Note: The validator keys will be loaded from the persistent volume created during DKG.

#### Example 1b: From a single node output (.charon/ structure)

When you have DKG artifacts in a `.charon/` directory:

```
.charon/
├── charon-enr-private-key
├── cluster-lock.json
└── validator_keys/
    ├── keystore-0.json
    └── keystore-0.txt
```

Create the required resources:
```console
# Create ENR private key secret
kubectl create secret generic charon-enr-private-key --from-file=.charon/charon-enr-private-key

# Create the cluster lock ConfigMap
kubectl create configmap my-cluster-lock --from-file=.charon/cluster-lock.json

# Install the chart, referencing your ConfigMap
helm install my-dv-pod obol/dv-pod \
  --set configMaps.clusterlock=my-cluster-lock
```

#### Handling Large Cluster-Lock Files (>1MB)

If your cluster-lock.json file is larger than 1MB, you may encounter errors when creating the ConfigMap:

```console
error validating data: ValidationError(ConfigMap.data.cluster-lock.json): invalid type for io.k8s.api.core.v1.ConfigMap.data: got "array", expected "string"
```

In this case, you have two options:

**Option A: Direct lock hash (Recommended)**

1. Extract the lock_hash from your cluster-lock.json:
   ```console
   LOCK_HASH=$(jq -r '.lock_hash' cluster-lock.json)
   echo $LOCK_HASH
   ```

2. Install the chart with the lockHash value:
   ```console
   helm install my-dv-pod obol/dv-pod \
     --set charon.lockHash=$LOCK_HASH \
     --set charon.operatorAddress=<YOUR_OPERATOR_ADDRESS>
   ```

**Option B: ConfigMap approach**

1. Extract the lock_hash and create a ConfigMap:
   ```console
   LOCK_HASH=$(jq -r '.lock_hash' cluster-lock.json)
   kubectl create configmap cluster-lock-hash \
     --from-literal=lock-hash=$LOCK_HASH
   ```

2. Install the chart referencing the ConfigMap:
   ```console
   helm install my-dv-pod obol/dv-pod \
     --set configMaps.lockHash=cluster-lock-hash \
     --set charon.operatorAddress=<YOUR_OPERATOR_ADDRESS>
   ```

The DKG sidecar will use the lock hash to fetch the full cluster lock from the Obol API.

### Option 2: Run DKG through the chart (automatic)

If you don't have pre-existing artifacts, the chart can automatically:
1. Generate an ENR private key (or use one you provide)
2. Run the DKG ceremony via the Obol API
3. Store the resulting artifacts in a persistent volume

Simply deploy the chart with your operator address:
```console
helm install my-dv-pod obol/dv-pod \
  --set charon.operatorAddress=0xYOUR_OPERATOR_ADDRESS
```

The DKG sidecar will poll the Obol API for cluster invites and automatically run the DKG ceremony when ready.

## Add Obol's Helm Charts Repo

```sh
helm repo add obol https://obolnetwork.github.io/helm-charts
helm repo update
```
_See [helm repo](https://helm.sh/docs/helm/helm_repo/) for command documentation._

## Install the chart
Install a distributed validator pod:
```sh
helm upgrade --install my-dv-pod obol/dv-pod \
  --set='charon.beaconNodeEndpoints[0]=<BEACON_NODE_ENDPOINT>' \
  --set='charon.operatorAddress=<YOUR_OPERATOR_ADDRESS>' \
  --create-namespace \
  --namespace dv-pod
```

## Validator Client

The dv-pod chart includes an integrated validator client that runs alongside Charon in the same pod. The validator client is automatically configured to connect to Charon's validator API.

### Supported Validator Clients

You can choose from the following validator clients using the `validatorClient.type` parameter:
- `lighthouse` (default)
- `teku`
- `nimbus`
- `lodestar`
- `prysm`

### Configuration Example

```yaml
validatorClient:
  enabled: true
  type: lighthouse
  config:
    graffiti: "My DV Pod"
    extraArgs:
      - --suggested-fee-recipient=0xYOUR_FEE_RECIPIENT_ADDRESS
```

### Validator Keystores

The chart supports two methods for providing validator keystores:

#### Option 1: Pre-existing Keystores (Recommended for Production)

If you have existing keystores, create a Kubernetes secret and reference it:

```console
# Create secret with your keystores
kubectl create secret generic validator-keys \
  --from-file=keystore-0.json \
  --from-file=keystore-0.txt \
  --from-file=keystore-1.json \
  --from-file=keystore-1.txt

# Deploy the chart with the keystore secret
helm install my-dv-pod obol/dv-pod \
  --set validatorClient.keystores.secretName=validator-keys \
  --set configMaps.clusterlock=my-cluster-lock
```

#### Option 2: DKG-Generated Keystores (Automatic)

When running DKG through the chart, keystores are automatically generated and imported to the validator client. The import process handles the specific directory structure required by each validator client:

- **Lighthouse**: Keystores in `/validator-data/validators/`, passwords in `/validator-data/secrets/`
- **Lodestar**: Restructured with pubkey directories under `/validator-data/keystores/`
- **Teku**: Keystores in `/validator-data/keys/`, passwords in `/validator-data/passwords/`
- **Prysm**: Keystores in `/validator-data/wallets/`
- **Nimbus**: Similar to Lighthouse structure

## Advanced Usage

### Use an External Validator Client

While the dv-pod chart includes an integrated validator client, you may want to use an external validator client instead. To do this:

1. Disable the integrated validator client:
```yaml
validatorClient:
  enabled: false
```

2. Configure your external validator client to connect to the Charon node's validator API endpoint:
```
--beacon-node-api-endpoint="http://<RELEASE_NAME>-dv-pod.<NAMESPACE>.svc.cluster.local:3600"
```

For example, if you installed the chart as `my-dv-pod` in namespace `dv-pod`:
```
--beacon-node-api-endpoint="http://my-dv-pod.dv-pod.svc.cluster.local:3600"
```

Note: The Charon validator API on port 3600 provides the same interface as a beacon node API, allowing standard validator clients to connect without modification.

## Uninstall the Chart
To uninstall and delete the `dv-pod` release:
```sh
helm uninstall dv-pod -n dv-pod
```
The command removes all the Kubernetes components associated with the chart and deletes the release.
