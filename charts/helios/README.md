
Charon Cluster
===========

![Version: 0.1.4](https://img.shields.io/badge/Version-0.1.4-informational?style=flat-square) ![Type: application](https://img.shields.io/badge/Type-application-informational?style=flat-square) ![AppVersion: 0.9.0](https://img.shields.io/badge/AppVersion-0.9.0-informational?style=flat-square)

A Helm chart for Helios - a trustless, efficient, and portable Ethereum light client

## Values

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| affinity | object | `{}` |  |
| autoscaling.enabled | bool | `false` |  |
| autoscaling.maxReplicas | int | `100` |  |
| autoscaling.minReplicas | int | `1` |  |
| autoscaling.targetCPUUtilizationPercentage | int | `80` |  |
| fullnameOverride | string | `""` |  |
| helios.checkpoint | string | `""` |  |
| helios.config.enabled | bool | `false` |  |
| helios.consensusRpc | string | `"https://www.lightclientdata.org"` |  |
| helios.dataDir | string | `"/data"` |  |
| helios.executionRpc | string | `"https://ethereum-rpc.publicnode.com"` |  |
| helios.fallback | string | `""` |  |
| helios.loadExternalFallback | bool | `false` |  |
| helios.network | string | `"mainnet"` |  |
| helios.rpcBindIp | string | `"127.0.0.1"` |  |
| helios.rpcPort | int | `8545` |  |
| helios.strictCheckpointAge | bool | `false` |  |
| image.pullPolicy | string | `"IfNotPresent"` |  |
| image.repository | string | `"obolnetwork/helios"` |  |
| image.tag | string | `"e10e753"` |  |
| imagePullSecrets | list | `[]` |  |
| ingress.annotations | object | `{}` |  |
| ingress.className | string | `""` |  |
| ingress.enabled | bool | `false` |  |
| ingress.hosts[0].host | string | `"chart-example.local"` |  |
| ingress.hosts[0].paths[0].path | string | `"/"` |  |
| ingress.hosts[0].paths[0].pathType | string | `"ImplementationSpecific"` |  |
| ingress.tls | list | `[]` |  |
| livenessProbe.httpGet.path | string | `"/health"` |  |
| livenessProbe.httpGet.port | string | `"http"` |  |
| livenessProbe.initialDelaySeconds | int | `30` |  |
| livenessProbe.periodSeconds | int | `10` |  |
| nameOverride | string | `""` |  |
| nodeSelector | object | `{}` |  |
| persistence.enabled | bool | `true` |  |
| persistence.mountPath | string | `"/data"` |  |
| persistence.size | string | `"1Gi"` |  |
| persistence.useVolumeClaimTemplates | bool | `true` |  |
| podAnnotations | object | `{}` |  |
| podLabels | object | `{}` |  |
| podSecurityContext | object | `{}` |  |
| readinessProbe.httpGet.path | string | `"/health"` |  |
| readinessProbe.httpGet.port | string | `"http"` |  |
| readinessProbe.initialDelaySeconds | int | `5` |  |
| readinessProbe.periodSeconds | int | `5` |  |
| replicaCount | int | `1` |  |
| resources | object | `{}` |  |
| securityContext | object | `{}` |  |
| service.port | int | `8545` |  |
| service.type | string | `"ClusterIP"` |  |
| serviceAccount.annotations | object | `{}` |  |
| serviceAccount.automount | bool | `true` |  |
| serviceAccount.create | bool | `true` |  |
| serviceAccount.name | string | `""` |  |
| tolerations | list | `[]` |  |
| volumeMounts | list | `[]` |  |
| volumes | list | `[]` |  |

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
