
DV-Pod
===========

![Version: 0.4.2](https://img.shields.io/badge/Version-0.4.2-informational?style=flat-square) ![Type: application](https://img.shields.io/badge/Type-application-informational?style=flat-square) ![AppVersion: 1.7.1](https://img.shields.io/badge/AppVersion-1.7.1-informational?style=flat-square)

A Helm chart for deploying a single distributed validator pod consisting of a Charon middleware client and validator client.

**Homepage:** <https://docs.obol.org/>

## Source Code

* <https://github.com/ObolNetwork/charon>

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

### Option 1: Pre-created keys and artifacts (skips DKG process)

If you already have private keys and charon artifacts from a central key creation or a DKG ceremony, you can provide them to skip the automated DKG process entirely.

#### Example 1a: From a `charon create cluster` command output (a `./cluster/nodeN` folder structure)

When you've created keystores for a full cluster locally and have a `./cluster/` directory:

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
```sh
# Put the ENR private key in a secret
kubectl create secret generic charon-enr-private-key --from-file=cluster/node0/charon-enr-private-key

# Put the private keys in a kubernetes secret
kubectl create secret generic validator-keys \
  --from-file=cluster/node0/validator_keys/keystore-0.json --from-file=cluster/node0/validator_keys/keystore-0.txt

# Create the cluster lock ConfigMap (same for all nodes)
kubectl create configmap cluster-lock --from-file=cluster/node0/cluster-lock.json

# Install the chart, referencing your ConfigMap and Secrets
helm install my-dv-pod obol/dv-pod \
  --set configMaps.clusterLock=cluster-lock \
  --set validatorClient.keystores.secretName=validator-keys
```

That should be enough to get your DV-Pod running, and loaded with the required artifacts, assuming the default beacon node endpoint of the Obol Stack works.

#### Example 1b: From a Distributed Key Generation ceremony output (a `.charon/` folder structure)

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

```sh
# Put the charon ENR private key in a kubernetes secret
kubectl create secret generic charon-enr-private-key \
  --from-file=.charon/charon-enr-private-key

# Put the private keys in a kubernetes secret
kubectl create secret generic validator-keys \
  --from-file=.charon/validator_keys/keystore-0.json --from-file=.charon/validator_keys/keystore-0.txt

# Put the cluster lock file in a kubernetes ConfigMap
kubectl create configmap cluster-lock \
  --from-file=.charon/cluster-lock.json

# Install the chart
helm install my-dv-pod obol/dv-pod \
  --set configMaps.clusterLock=cluster-lock \
  --set validatorClient.keystores.secretName=validator-keys
```

> [!IMPORTANT]
> The ENR secret MUST be created in the same namespace where you plan to install the Helm chart. The ENR job can only look for secrets in its own namespace.

### Option 2: Run DKG through the chart (automatic)

If you don't have pre-existing artifacts, the chart can automatically:
1. Generate an ENR private key (or use one you provide)
2. Run the DKG ceremony via the Obol API
3. Store the resulting artifacts in a persistent volume

Simply deploy the chart with your operator address:
```sh
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
  --set='charon.operatorAddress=<YOUR_OPERATOR_ADDRESS>'
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

Changing VC with a values.yaml file:

```yaml
validatorClient:
  enabled: true
  type: lighthouse
  config:
    graffiti: "My DV Pod"
    extraArgs:
      - --suggested-fee-recipient=0xYOUR_FEE_RECIPIENT_ADDRESS
```

With a `helm install` command for pre-existing artifacts.

```sh
helm install my-dv-pod obol/dv-pod \
  --set configMaps.clusterLock=cluster-lock \
  --set validatorClient.keystores.secretName=validator-keys \
  --set validatorClient.type=prysm --set validatorClient.config.prysm.acceptTermsOfUse=true
```

> [!NOTE]
> To run Prysm VC you must accept their [Terms of Use](https://github.com/OffchainLabs/prysm/blob/develop/TERMS_OF_SERVICE.md).

### Validator Keystores

The chart supports two methods for providing validator keystores:

#### Option 1: Pre-existing Keystores (Recommended for Production)

If you have existing keystores, create a Kubernetes secret and reference it:

```sh
# Create secret with your keystores
kubectl create secret generic validator-keys \
  --from-file=keystore-0.json \
  --from-file=keystore-0.txt \
  --from-file=keystore-1.json \
  --from-file=keystore-1.txt

# Deploy the chart with the keystore secret
helm install my-dv-pod obol/dv-pod \
  --set validatorClient.keystores.secretName=validator-keys \
  --set configMaps.clusterLock=my-cluster-lock
```

#### Option 2: DKG-Generated Keystores (Automatic)

When running DKG through the chart, keystores are automatically generated and imported to the validator client. The import process handles the specific directory structure required by each validator client:

- **Lighthouse**: Keystores in `/validator-data/validators/`, passwords in `/validator-data/secrets/`
- **Lodestar**: Restructured with pubkey directories under `/validator-data/keystores/`
- **Teku**: Keystores in `/validator-data/keys/`, passwords in `/validator-data/passwords/`
- **Prysm**: Keystores in `/validator-data/wallets/`
- **Nimbus**: Similar to Lighthouse structure

## Namespace Requirements

### ENR Secret Management

The ENR (Ethereum Node Record) secret **MUST** be created in the same namespace as the Helm release. The chart's ENR job will only check for existing secrets within its own namespace (`.Release.Namespace`).

**Common Pitfall**: Creating the ENR secret in a different namespace (e.g., `dv-pod`) and then installing the chart in another namespace (e.g., `default`) will result in the ENR job generating a new ENR, potentially overriding your intended configuration.

**Best Practice**: Always ensure your secrets and Helm release are in the same namespace:

```bash
# Wrong approach - secret and chart in different namespaces
kubectl create secret generic charon-enr-private-key -n dv-pod --from-literal=...
helm install my-dv-pod obol/dv-pod  # Installs in default namespace - ENR will be regenerated!

# Correct approach - both in same namespace
kubectl create secret generic charon-enr-private-key -n dv-pod --from-literal=...
helm install my-dv-pod obol/dv-pod -n dv-pod  # Both in dv-pod namespace
```

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

### Handling Large Cluster-Lock Files (>1MB)

If your `cluster-lock.json` file is larger than 1MB, you may encounter errors when creating the ConfigMap:

```sh
error validating data: ValidationError(ConfigMap.data.cluster-lock.json): invalid type for io.k8s.api.core.v1.ConfigMap.data: got "array", expected "string"
```

In this case, you have two options:

**Option A: Direct lock hash (Recommended)**

1. Extract the lock_hash from your cluster-lock.json:
   ```sh
   LOCK_HASH=$(jq -r '.lock_hash' cluster-lock.json)
   echo $LOCK_HASH
   ```

2. Install the chart with the lockHash value:
   ```sh
   helm install my-dv-pod obol/dv-pod \
     --set charon.lockHash=$LOCK_HASH \
     --set charon.operatorAddress=<YOUR_OPERATOR_ADDRESS>
   ```

**Option B: ConfigMap approach**

1. Extract the lock_hash and create a ConfigMap:
   ```sh
   LOCK_HASH=$(jq -r '.lock_hash' cluster-lock.json)
   kubectl create configmap cluster-lock-hash \
     --from-literal=lock-hash=$LOCK_HASH
   ```

2. Install the chart referencing the ConfigMap:
   ```sh
   helm install my-dv-pod obol/dv-pod \
     --set configMaps.lockHash=cluster-lock-hash \
     --set charon.operatorAddress=<YOUR_OPERATOR_ADDRESS>
   ```

The DKG sidecar will use the lock hash to fetch the full cluster lock from the Obol API.

## Uninstall the Chart
To uninstall and delete the `dv-pod` release:
```sh
helm uninstall dv-pod -n dv-pod
```
The command removes all the Kubernetes components associated with the chart and deletes the release.

## Full Chart Values Reference

## Values

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| affinity | object | `{}` | Affinity for pod assignment # ref: https://kubernetes.io/docs/concepts/configuration/assign-pod-node/#affinity-and-anti-affinity # # Example: # affinity: #   podAntiAffinity: #     requiredDuringSchedulingIgnoredDuringExecution: #     - labelSelector: #         matchExpressions: #         - key: app.kubernetes.io/name #           operator: In #           values: #           - charon #       topologyKey: kubernetes.io/hostname # |
| centralMonitoring | object | `{"enabled":false,"promEndpoint":"https://vm.monitoring.gcp.obol.tech/write","token":""}` | Central Monitoring |
| centralMonitoring.enabled | bool | `false` | Specifies whether central monitoring should be enabled |
| centralMonitoring.promEndpoint | string | `"https://vm.monitoring.gcp.obol.tech/write"` | https endpoint to obol central prometheus  |
| centralMonitoring.token | string | `""` | The authentication token to the central prometheus |
| charon.beaconNodeEndpoints | list | `["http://l1-full-node-beacon.l1.cluster.svc.local:5052"]` | Beacon node endpoints The default is the Obol Stack full node address. Change this to your own consensus client beacon API(s). All beacon nodes specified here will be called for every charon request, if you want to leverage fallback behaviour place secondary beacon nodes in charon.fallbackBeaconNodeEndpoints[] |
| charon.beaconNodeHeaders | string | `""` | Beacon node authentication headers WARNING: These headers will be sent to ALL beacon nodes, which could leak credentials Format: "Authorization=Basic <base64_encoded_credentials>" To generate: echo -n "username:password" | base64 Example: "Authorization=Basic am9objpkb2U=" |
| charon.beaconNodeHeadersSecretKey | string | `"headers"` | Optional: Key within the charon.beaconNodeHeaders secret to read from |
| charon.beaconNodeHeadersSecretName | string | `""` | Optional: Name of the secret containing beacon node headers Use this for secure credential storage instead of beaconNodeHeaders The secret should contain a key specified by charon.beaconNodeHeadersSecretKey |
| charon.builderApi | string | `"true"` | Enables the builder api (MEV) for validator proposals. The Builder API must also be enabled on your beacon node client(s).  The Beacon node must either be connected to a mev sidecar or a mev relay to access the builder network. More documentation about MEV can be found [here](https://docs.obol.org/advanced-and-troubleshooting/advanced/enable-mev). |
| charon.directConnectionEnabled | string | `"true"` | If enabled, it will set p2pExternalHostname value to the pod name and enable direct connection between cluster nodes. This is useful for deployments where pods can directly communicate with each other. |
| charon.dkgSidecar | object | `{"apiEndpoint":"https://api.obol.tech","enabled":true,"image":{"pullPolicy":"IfNotPresent","repository":"obolnetwork/charon-dkg-sidecar","tag":"main"},"initialRetryDelaySeconds":10,"maxRetryDelaySeconds":300,"pageLimit":10,"resources":{"limits":{"cpu":"200m","memory":"256Mi"},"requests":{"cpu":"50m","memory":"128Mi"}},"retryDelayFactor":2,"retryDelaySeconds":10,"serviceAccount":{"create":true},"targetConfigHash":""}` | Configuration for the DKG Sidecar init container This init container orchestrates the Distributed Key Generation (DKG) process for Charon clusters.  The sidecar has three operating modes: 1. If cluster-lock.json exists: Exits immediately (cluster already initialized) 2. If cluster-definition.json exists: Attempts DKG with the existing definition 3. If neither exists: Polls the Obol API for cluster invites and runs DKG when ready  To provide a pre-existing cluster-lock and skip DKG: 1. Create a configMap: kubectl create configmap cluster-lock --from-file=cluster-lock.json 2. Change the `confiMaps.clusterLock: cluster-lock in your values.yaml file,    or pass --set configMaps.clusterLock=cluster-lock in your helm install command. 3. The sidecar will detect the mounted lock file and exit, allowing Charon to start immediately  To provide a cluster-definition without running DKG through the API: 1. Mount your cluster-definition.json in /charon-data/ 2. The sidecar will run 'charon dkg' to generate the cluster-lock.json  Note: When providing a pre-existing cluster-lock.json, you must also ensure the associated validator keys are available in the charon-data volume. |
| charon.dkgSidecar.apiEndpoint | string | `"https://api.obol.tech"` | API endpoint for the Obol network to fetch cluster definitions |
| charon.dkgSidecar.image.repository | string | `"obolnetwork/charon-dkg-sidecar"` | Image repository for the DKG sidecar |
| charon.dkgSidecar.initialRetryDelaySeconds | int | `10` | Initial delay in seconds before the first retry of a polling cycle. |
| charon.dkgSidecar.maxRetryDelaySeconds | int | `300` | Maximum delay in seconds for exponential backoff between polling cycles. |
| charon.dkgSidecar.pageLimit | int | `10` | Page limit for API calls when fetching cluster definitions |
| charon.dkgSidecar.resources | object | `{"limits":{"cpu":"200m","memory":"256Mi"},"requests":{"cpu":"50m","memory":"128Mi"}}` | Resources for the cluster poller init container |
| charon.dkgSidecar.retryDelayFactor | int | `2` | Factor by which the retry delay increases after each polling cycle (e.g., 2 for doubling). |
| charon.dkgSidecar.retryDelaySeconds | int | `10` | Delay in seconds between polling retries |
| charon.dkgSidecar.serviceAccount | object | `{"create":true}` | Service account settings for test pods |
| charon.dkgSidecar.targetConfigHash | string | `""` | Target cluster definition config hash for the DKG sidecar to partake in (optional). Must be a valid 32-byte hex hash with 0x prefix (66 characters total). Example: "0x7f0fd29abb11674b4e61000de26bff3600237aab0402427bd1409756665c2115" |
| charon.enr.existingSecret | object | `{"name":"","privateKeyDataKey":"charon-enr-private-key","publicKeyDataKey":"enr"}` | Point to an existing Kubernetes secret that holds the ENR private key. If 'privateKey' above is not set and this 'existingSecret.name' is provided, 'generate' is ignored. NOTE: If not set, the chart will automatically check for a secret named 'charon-enr-private-key' (configurable via secrets.defaultEnrPrivateKey) and use it if it exists. |
| charon.enr.existingSecret.privateKeyDataKey | string | `"charon-enr-private-key"` | Key in the secret's 'data' field holding the private key hex string |
| charon.enr.existingSecret.publicKeyDataKey | string | `"enr"` | Key in the secret's 'data' field holding the public ENR string |
| charon.enr.generate | object | `{"annotations":{},"enabled":true,"image":{"pullPolicy":"IfNotPresent","repository":"obolnetwork/charon","tag":"v1.7.1"},"kubectlImage":{"pullPolicy":"IfNotPresent","repository":"bitnamisecure/kubectl","tag":"latest"},"nodeSelector":{}}` | Enable automatic generation of an ENR private key. Only used if 'privateKey' and 'existingSecret.name' are not provided. The generated key will be stored in a secret with data keys 'charon-enr-private-key' and 'enr'. |
| charon.enr.generate.annotations | object | `{}` | Annotations to add to the ENR generation job |
| charon.enr.generate.kubectlImage | object | `{"pullPolicy":"IfNotPresent","repository":"bitnamisecure/kubectl","tag":"latest"}` | Image to use for kubectl operations within the ENR generation job This image must contain a compatible kubectl binary. |
| charon.enr.generate.nodeSelector | object | `{}` | Node selector for the ENR generation job |
| charon.enr.privateKey | string | `""` | Provide the ENR private key directly (hex format, e.g., 0x...).  If set, 'generate' and 'existingSecret' are ignored. |
| charon.enrJob.enabled | bool | `true` | Enable or disable the Kubernetes Job that generates/manages the ENR. Note: This is typically not needed as the job automatically detects existing secrets. The job will check if the ENR secret already exists and skip generation if found. Only set to false for advanced use cases where you need to completely disable the job. |
| charon.executionClientRpcEndpoint | string | `""` | Optional: Execution client RPC endpoint URL (e.g., your Ethereum execution client) Note: Charon currently only supports a single execution endpoint This is only needed if an operator in the cluster uses a smart contract wallet for an operator signature.  If that does not apply to this cluster, this field can be left unset. |
| charon.fallbackBeaconNodeEndpoints | list | `["https://ethereum-beacon-api.publicnode.com"]` | Fallback beacon node endpoints (optional) These will be used if the primary beaconNodeEndpoints are unavailable |
| charon.featureSet | string | `"stable"` | Minimum feature set to enable by default: alpha, beta, or stable. Warning: modify at own risk. (default "stable") |
| charon.featureSetDisable | string | `""` | Comma-separated list of features to disable, overriding the default minimum feature set. |
| charon.featureSetEnable | string | `""` | Comma-separated list of features to enable, overriding the default minimum feature set. |
| charon.lockFile | string | `"/charon-data/cluster-lock.json"` | The path on the pod to the cluster lock file that definesthe distributed validator cluster. (default "/charon-data/cluster-lock.json") |
| charon.lockHash | string | `""` | Cluster lock hash for large cluster-lock files (>1MB) When provided, the DKG sidecar will fetch the full cluster-lock from Obol API using this hash Extract the hash from a cluster-lock.json using: `jq -r '.lock_hash' cluster-lock.json` Alternative to providing the full cluster-lock.json file via the configMaps.clusterLock value |
| charon.logFormat | string | `"json"` | Log format; console, logfmt or json (default "json") |
| charon.logLevel | string | `"info"` | Log level; debug, info, warn or error (default "info") |
| charon.lokiAddresses | string | `""` | Enables sending of logfmt structured logs to these Loki log aggregation server addresses. This is in addition to normal stderr logs. |
| charon.lokiService | string | `""` | Service label sent with logs to Loki. |
| charon.monitoringAddress | string | `"0.0.0.0:3620"` | Listening address (ip and port) for the monitoring API (prometheus, pprof). (default "127.0.0.1:3620") |
| charon.nickname | string | `""` | The nickname this Charon appears as in monitoring and its peer's logs. Maximum 32 characters. |
| charon.noVerify | bool | `false` | Disables cluster definition and lock file verification. |
| charon.operatorAddress | string | `""` | The Ethereum address of this operator. This MUST be provided by the user to use the auto-dkg functionality. |
| charon.p2pAllowlist | string | `""` | Comma-separated list of CIDR subnets for allowing only certain peer connections. Example: 192.168.0.0/16 would permit connections to peers on your local network only. The default is to accept all connections. |
| charon.p2pDenylist | string | `""` | Comma-separated list of CIDR subnets for disallowing certain peer connections. Example: 192.168.0.0/16 would disallow connections to peers on your local network. The default is to accept all connections. |
| charon.p2pDisableReuseport | string | `""` | Disables TCP port reuse for outgoing libp2p connections. |
| charon.p2pExternalHostname | string | `""` | The DNS hostname advertised by libp2p. This may be used to advertise an external DNS. |
| charon.p2pExternalIp | string | `""` | The IP address advertised by libp2p. This may be used to advertise an external IP. |
| charon.p2pRelays | string | `""` | Comma-separated list of libp2p relay URLs or multiaddrs. Default list is provided by libp2p and may change over time |
| charon.p2pTcpAddress | string | `"0.0.0.0:3610"` | Comma-separated list of listening TCP addresses (ip and port) for libP2P traffic. Empty default doesn't bind to local port therefore only supports outgoing connections. |
| charon.privateKeyFile | string | `"/data/charon-enr-private-key"` | Path within the Charon container where the ENR private key file will be mounted. |
| charon.validatorApiAddress | string | `"0.0.0.0:3600"` | Listening address (ip and port) for validator-facing traffic proxying the beacon-node API. (default "127.0.0.1:3600") |
| clusterThreshold | string | `""` | Maximum number of pods that can be unavailable for cluster threshold Used in pod disruption budget when minAvailable is not specified |
| configMaps | object | `{"clusterLock":""}` | Kubernetes configMaps names for non-sensitive configuration data. |
| configMaps.clusterLock | string | `""` | Name of the ConfigMap containing the cluster-lock.json file Set this to the name of an existing ConfigMap to skip the DKG process. Example: kubectl create configmap cluster-lock --from-file=.charon/cluster-lock.json Then set: clusterLock: "cluster-lock" If not set or if the ConfigMap doesn't exist, the DKG process will run. NOTE: For large cluster-lock files (>1MB), use charon.lockHash instead clusterLock: "cluster-lock" |
| containerSecurityContext | object | See `values.yaml` | The security context for containers |
| fullnameOverride | string | `""` | Provide a name to substitute for the full names of resources |
| global | object | `{"annotations":{}}` | Global configuration that can be referenced across the chart Used for test configurations and shared settings |
| global.annotations | object | `{}` | Global annotations applied to resources |
| image | object | `{"pullPolicy":"IfNotPresent","repository":"obolnetwork/charon","tag":"v1.7.1"}` | Charon image repository, pull policy, and tag version |
| imagePullSecrets | list | `[]` | Credentials to fetch images from private registry # ref: https://kubernetes.io/docs/tasks/configure-pod-container/pull-image-private-registry/ |
| livenessProbe | object | `{"enabled":false,"httpGet":{"path":"/livez","port":3620},"initialDelaySeconds":10,"periodSeconds":5}` | Configure liveness probes # ref: https://kubernetes.io/docs/tasks/configure-pod-container/configure-liveness-readiness-startup-probes/ |
| livenessProbe.httpGet.port | int | `3620` | Port for liveness probe HTTP checks |
| nameOverride | string | `""` | Provide a name in place of charon for `app:` labels |
| network | string | `"mainnet"` | Network name for the Ethereum network Supported values: mainnet, sepolia, hoodi The chainId is automatically derived from the network name |
| networkPolicy | object | `{"beaconNodes":{"enabled":true,"ipBlock":{},"namespaceSelector":{},"podSelector":{},"port":null},"customEgress":[],"customIngress":[],"enabled":false,"monitoring":{"enabled":true,"namespaceSelector":{},"podSelector":{}},"obolApi":{"cidr":"0.0.0.0/0","enabled":true,"except":[]},"validatorClientNamespaceSelector":{},"validatorClientSelector":{}}` | NetworkPolicy configuration for pod network isolation |
| networkPolicy.beaconNodes | object | `{"enabled":true,"ipBlock":{},"namespaceSelector":{},"podSelector":{},"port":null}` | Beacon node configuration |
| networkPolicy.beaconNodes.enabled | bool | `true` | Enable egress to beacon nodes |
| networkPolicy.beaconNodes.ipBlock | object | `{}` | IP block for external beacon nodes |
| networkPolicy.beaconNodes.namespaceSelector | object | `{}` | Namespace selector for beacon nodes |
| networkPolicy.beaconNodes.podSelector | object | `{}` | Pod selector for beacon nodes |
| networkPolicy.beaconNodes.port | string | `nil` | Port for beacon node connections (leave empty for any port) |
| networkPolicy.customEgress | list | `[]` | Custom egress rules to add |
| networkPolicy.customIngress | list | `[]` | Custom ingress rules to add |
| networkPolicy.enabled | bool | `false` | Enable NetworkPolicy to restrict network traffic |
| networkPolicy.monitoring | object | `{"enabled":true,"namespaceSelector":{},"podSelector":{}}` | Monitoring configuration |
| networkPolicy.monitoring.enabled | bool | `true` | Enable access from monitoring tools |
| networkPolicy.monitoring.namespaceSelector | object | `{}` | Namespace selector for monitoring namespace |
| networkPolicy.monitoring.podSelector | object | `{}` | Pod selector for monitoring tools (e.g., Prometheus) |
| networkPolicy.obolApi | object | `{"cidr":"0.0.0.0/0","enabled":true,"except":[]}` | Obol API configuration |
| networkPolicy.obolApi.cidr | string | `"0.0.0.0/0"` | CIDR block for Obol API access |
| networkPolicy.obolApi.enabled | bool | `true` | Enable egress to Obol API for DKG |
| networkPolicy.obolApi.except | list | `[]` | IP ranges to exclude |
| networkPolicy.validatorClientNamespaceSelector | object | `{}` | Namespace selector for validator client access |
| networkPolicy.validatorClientSelector | object | `{}` | Selector for validator client pods that can access the validator API |
| nodeSelector | object | `{}` | Node labels for pod assignment # ref: https://kubernetes.io/docs/user-guide/node-selection/ |
| persistence | object | `{"accessModes":["ReadWriteOnce"],"annotations":{},"enabled":true,"size":"1Gi","validatorDataSize":"500Mi"}` | Persistence configuration for DKG artifacts and charon data |
| persistence.accessModes | list | `["ReadWriteOnce"]` | Access modes for the PVC. Must be a list. Default: ["ReadWriteOnce"]. |
| persistence.annotations | object | `{}` | Annotations for the PVC Example: annotations: {"volume.beta.kubernetes.io/storage-class": "fast"} |
| persistence.enabled | bool | `true` | Enable persistence using a PersistentVolumeClaim. |
| persistence.size | string | `"1Gi"` | Size of the PVC for charon-data. |
| persistence.validatorDataSize | string | `"500Mi"` | Size of the PVC for validator-data. Validator data includes slashing protection DB and other validator state. NOTE: Validator data ALWAYS uses persistent storage to prevent slashing, even if persistence.enabled is false for charon-data. |
| podAnnotations | object | `{"pod-security.kubernetes.io/audit":"baseline","pod-security.kubernetes.io/audit-version":"latest","pod-security.kubernetes.io/enforce":"baseline","pod-security.kubernetes.io/enforce-version":"latest","pod-security.kubernetes.io/warn":"baseline","pod-security.kubernetes.io/warn-version":"latest"}` | Pod annotations |
| podDisruptionBudget | object | `{"enabled":true,"minAvailable":""}` | Enable pod disruption budget # ref: https://kubernetes.io/docs/tasks/run-application/configure-pdb |
| priorityClassName | string | `""` | Used to assign priority to pods # ref: https://kubernetes.io/docs/concepts/configuration/pod-priority-preemption/ |
| rbac | object | `{"clusterRules":[{"apiGroups":[""],"resources":["nodes"],"verbs":["get","list","watch"]}],"enabled":true,"name":"","rules":[{"apiGroups":[""],"resources":["services"],"verbs":["get","list","watch"]}]}` | RBAC configuration. # ref: https://kubernetes.io/docs/reference/access-authn-authz/rbac/ |
| rbac.clusterRules | list | `[{"apiGroups":[""],"resources":["nodes"],"verbs":["get","list","watch"]}]` | Required ClusterRole rules |
| rbac.clusterRules[0] | object | `{"apiGroups":[""],"resources":["nodes"],"verbs":["get","list","watch"]}` | Required to obtain the nodes external IP |
| rbac.enabled | bool | `true` | Specifies whether RBAC resources are to be created |
| rbac.name | string | `""` | The name of the cluster role to use. If not set and create is true, a name is generated using the fullname template |
| rbac.rules | list | `[{"apiGroups":[""],"resources":["services"],"verbs":["get","list","watch"]}]` | Required Role rules |
| rbac.rules[0] | object | `{"apiGroups":[""],"resources":["services"],"verbs":["get","list","watch"]}` | Required to get information about the serices nodePort. |
| readinessProbe | object | `{"enabled":false,"httpGet":{"path":"/readyz","port":3620},"initialDelaySeconds":5,"periodSeconds":3}` | Configure readiness probes # ref: https://kubernetes.io/docs/tasks/configure-pod-container/configure-liveness-readiness-startup-probes/ |
| readinessProbe.httpGet.port | int | `3620` | Port for readiness probe HTTP checks |
| resources | object | `{"limits":{"cpu":"2000m","memory":"4Gi"},"requests":{"cpu":"1000m","memory":"2Gi"}}` | Pod resources limits and requests |
| secrets | object | `{"defaultEnrPrivateKey":"charon-enr-private-key"}` | Kubernetes secrets names For the ENR, the secret name is either defined in 'charon.enr.existingSecret.name' or generated by the ENR job (e.g., {{ .Release.Name }}-dv-pod-enr-key). |
| secrets.defaultEnrPrivateKey | string | `"charon-enr-private-key"` | Default ENR private key secret name to check for auto-detection IMPORTANT: This secret MUST exist in the same namespace as the Helm release If this secret exists in the release namespace, it will be used automatically unless explicitly overridden by charon.enr.existingSecret.name The ENR job will NOT check other namespaces to prevent unexpected behavior |
| securityContext | object | See `values.yaml` | The security context for pods Note: This must be set to null or omit runAsNonRoot to allow the prepare-validator-data init container to run as root for setting file permissions |
| service | object | `{"clusterIP":"None","ports":{"monitoring":{"name":"monitoring","port":3620,"protocol":"TCP","targetPort":3620},"p2pTcp":{"name":"p2p-tcp","port":3610,"protocol":"TCP","targetPort":3610},"validatorApi":{"name":"validator-api","port":3600,"protocol":"TCP","targetPort":3600}}}` | Charon service ports |
| service.clusterIP | string | `"None"` | Headless service to create DNS for each statefulset instance |
| serviceAccount | object | `{"annotations":{},"enabled":true,"name":"","nameTest":""}` | Service account # ref: https://kubernetes.io/docs/tasks/configure-pod-container/configure-service-account/ |
| serviceAccount.annotations | object | `{}` | Annotations to add to the service account |
| serviceAccount.enabled | bool | `true` | Specifies whether a service account should be created |
| serviceAccount.name | string | `""` | The name of the service account to use. If not set, a name is generated using the default template |
| serviceAccount.nameTest | string | `""` | The name of the service account to use for test pods. If not set, uses the main service account |
| serviceMonitor | object | `{"annotations":{},"enabled":false,"interval":"1m","labels":{},"namespace":null,"path":"/metrics","relabelings":[],"scheme":"http","scrapeTimeout":"30s","tlsConfig":{}}` | Prometheus Service Monitor # ref: https://github.com/coreos/prometheus-operator |
| serviceMonitor.annotations | object | `{}` | Additional ServiceMonitor annotations |
| serviceMonitor.enabled | bool | `false` | If true, a ServiceMonitor CRD is created for a prometheus operator. https://github.com/coreos/prometheus-operator TODO: SWITCH BACK TO ON FOR PRODUCTION |
| serviceMonitor.interval | string | `"1m"` | ServiceMonitor scrape interval |
| serviceMonitor.labels | object | `{}` | Additional ServiceMonitor labels |
| serviceMonitor.namespace | string | `nil` | Alternative namespace for ServiceMonitor |
| serviceMonitor.path | string | `"/metrics"` | Path to scrape |
| serviceMonitor.relabelings | list | `[]` | ServiceMonitor relabelings |
| serviceMonitor.scheme | string | `"http"` | ServiceMonitor scheme |
| serviceMonitor.scrapeTimeout | string | `"30s"` | ServiceMonitor scrape timeout |
| serviceMonitor.tlsConfig | object | `{}` | ServiceMonitor TLS configuration |
| tests | object | `{"dkgSidecar":{"enabled":true,"hostNetwork":false,"mockApi":{"image":{"pullPolicy":"Always"},"port":3001},"operatorAddress":"0x3D1f0598943239806A251899016EAf4920d4726d","serviceAccount":{"create":true},"targetConfigHash":"0x7f0fd29abb11674b4e61000de26bff3600237aab0402427bd1409756665c2115"},"validatorKeystore":{"enabled":false,"mockKeystoreCount":2,"validatorClientType":"lodestar"}}` | Configuration for running Helm tests. These values are typically only used when `helm test` is run. |
| tests.dkgSidecar | object | `{"enabled":true,"hostNetwork":false,"mockApi":{"image":{"pullPolicy":"Always"},"port":3001},"operatorAddress":"0x3D1f0598943239806A251899016EAf4920d4726d","serviceAccount":{"create":true},"targetConfigHash":"0x7f0fd29abb11674b4e61000de26bff3600237aab0402427bd1409756665c2115"}` | The operator address to use for DKG sidecar tests. This should be a valid Ethereum address (0x...). |
| tests.dkgSidecar.hostNetwork | bool | `false` | Host network setting for dkgSidecar test pods |
| tests.dkgSidecar.serviceAccount | object | `{"create":true}` | Service account settings for test pods |
| tests.dkgSidecar.targetConfigHash | string | `"0x7f0fd29abb11674b4e61000de26bff3600237aab0402427bd1409756665c2115"` | Target config hash for testing (optional) When set, enables test-target-config-hash-set.yaml test and passes hash to DKG sidecar tests |
| tests.validatorKeystore | object | `{"enabled":false,"mockKeystoreCount":2,"validatorClientType":"lodestar"}` | Validator keystore configuration test |
| tests.validatorKeystore.enabled | bool | `false` | Enable validator keystore configuration tests |
| tests.validatorKeystore.mockKeystoreCount | int | `2` | Number of mock keystores to generate for testing |
| tests.validatorKeystore.validatorClientType | string | `"lodestar"` | Validator client type to test (lodestar, lighthouse, teku, prysm, nimbus) Currently lodestar, prysm, and nimbus are implemented |
| tolerations | object | `{}` | Tolerations for pod assignment # ref: https://kubernetes.io/docs/concepts/configuration/taint-and-toleration/ |
| updateStrategy | string | `"RollingUpdate"` | allows you to configure and disable automated rolling updates for containers, labels, resource request/limits, and annotations for the Pods in a StatefulSet. |
| validatorClient | object | `{"config":{"extraArgs":[],"graffiti":"","network":"","prysm":{"extraArgs":[]}},"enabled":true,"image":{"pullPolicy":"IfNotPresent","repository":"","tag":""},"keystores":{"secretName":""},"resources":{"limits":{"cpu":"1000m","memory":"2Gi"},"requests":{"cpu":"500m","memory":"1Gi"}},"type":"lighthouse"}` | Validator client configuration |
| validatorClient.config | object | `{"extraArgs":[],"graffiti":"","network":"","prysm":{"extraArgs":[]}}` | Validator client specific configuration |
| validatorClient.config.extraArgs | list | `[]` | Additional CLI arguments passed to the validator client (regardless of type) (the minimum required mev flags are automatically included when you set .Values.charon.builderApi to true) |
| validatorClient.config.graffiti | string | `""` | Graffiti to include in proposed blocks Leaving it unset will result in charon defaults. |
| validatorClient.config.network | string | `""` | Network configuration for validator client (e.g., mainnet, sepolia) Used by some validator clients like Teku for network-specific configuration |
| validatorClient.config.prysm | object | `{"extraArgs":[]}` | Configuration for the prysm validator client specifically Used to pass Prysm VC specific configuration NOTE: By using Prysm, you automatically accept the Terms of Service: https://github.com/prysmaticlabs/prysm/blob/develop/TERMS_OF_SERVICE.md |
| validatorClient.config.prysm.extraArgs | list | `[]` | Additional CLI arguments passed to the Prysm validator client only |
| validatorClient.enabled | bool | `true` | Enable the validator client container If you want to use an externally managed validator client.  Set this to false, and set your external validator to communicate with the 'validator-api' service created by this chart as if it were a beacon node API.  |
| validatorClient.image | object | `{"pullPolicy":"IfNotPresent","repository":"","tag":""}` | Image configuration for validator client Repository and tag will be auto-selected based on validator client type if not specified |
| validatorClient.keystores | object | `{"secretName":""}` | Validator keystores configuration |
| validatorClient.keystores.secretName | string | `""` | Name of the Secret containing validator keystores If provided, skip keystore generation and use existing keys The secret should contain keystore-*.json and keystore-*.txt files Example: kubectl create secret generic validator-keys --from-file=keystore-0.json --from-file=keystore-0.txt secretName: "validator-keys" |
| validatorClient.resources | object | `{"limits":{"cpu":"1000m","memory":"2Gi"},"requests":{"cpu":"500m","memory":"1Gi"}}` | Resource limits and requests for validator client |
| validatorClient.type | string | `"lighthouse"` | Type of validator client to use Options: lighthouse, teku, prysm, nimbus, lodestar |