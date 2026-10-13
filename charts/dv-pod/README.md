
DV-Pod
===========

![Version: 0.22.0](https://img.shields.io/badge/Version-0.22.0-informational?style=flat-square) ![Type: application](https://img.shields.io/badge/Type-application-informational?style=flat-square) ![AppVersion: 1.11.0](https://img.shields.io/badge/AppVersion-1.11.0-informational?style=flat-square)

A Helm chart for deploying a single distributed validator pod consisting of a Charon middleware client and validator client.

**Homepage:** <https://docs.obol.org/>

## Source Code

* <https://github.com/ObolNetwork/charon>

For a quick start guide, please refer to [QUICKSTART.md](./QUICKSTART.md).

# How to use this chart

A distributed validator cluster is composed of the following containers:

- Single execution layer client
- Single consensus layer client
- Number of Distributed Validator clients [This chart]
- Number of Validator clients
- Prometheus, Grafana and Jaeger clients for monitoring this cluster.

![Distributed Validator Cluster](https://github.com/ObolNetwork/charon-distributed-validator-cluster/blob/main/DVCluster.png?raw=true)

## Choosing a mode

Each operator in a DV cluster runs one `dv-pod` release. How the node joins its cluster is set by `mode`:

| `mode` | Use when | Required values |
|---|---|---|
| `auto` (default) | Existing installs; infers one of the modes below from the values you set | as for the inferred mode |
| `launchpad` | Operators create/accept the cluster on [launchpad.obol.org](https://launchpad.obol.org) | `charon.operatorAddress` |
| `definition` | Someone ran `charon create dkg` and shares the definition (config hash, URL or file) | exactly one of `dkg.definition.configHash`, `.url`, `.configMap` |
| `lock` | You already have a `cluster-lock.json` and key shares | `configMaps.clusterLock` (+ `validatorClient.keystores.secretName`) |
| `lockHash` | Same, but the lock is over 1MB | `charon.lockHash` (+ `validatorClient.keystores.secretName`) |

Missing or conflicting values fail at `helm install` time with a message naming the value to set.

In `launchpad` and `definition` modes the pod runs these init containers before charon starts:

1. `dkg-sidecar` waits until a fully signed definition containing this node's ENR is available.
2. `charon-dkg` (`dkg.runner: charon`, the default) runs `charon dkg` with the chart's own charon `image`, so the
   DKG always uses the same charon version as `charon run`. It retries until every operator is online, and never
   deletes anything from the data directory.
3. `dkg-report` records the result in the status ConfigMap.
4. Validator key import for the chosen validator client.

`dkg.runner: sidecar` keeps the pre-0.22 behaviour, where the sidecar runs the charon binary bundled in its image.

> [!IMPORTANT]
> `dkg.runner: charon`, `mode: definition` and status reporting need `obolnetwork/charon-dkg-sidecar:1.1.0`
> (the chart default). Until that tag is published, pods using it stay in `ErrImagePull`; pin an older tag with
> `charon.dkgSidecar.image.tag` and `dkg.runner: sidecar` if you need the legacy flow meanwhile.

## Reading the ENR and DKG progress (no Secret access needed)

The ENR job writes this node's public ENR to the ConfigMap `<fullname>-enr`, and the sidecar keeps the ConfigMap
`<fullname>-dkg-status` up to date (`phase`, `message`, `signatures`, `configHash`, `lockHash`, ...):

```sh
kubectl get configmap my-dv-pod-enr -n dv-pod -o jsonpath='{.data.enr}'
kubectl get configmap my-dv-pod-dkg-status -n dv-pod -o jsonpath='{.data.phase}{"\n"}{.data.message}{"\n"}'
```

Phases: `Initializing`, `WaitingForInvite`, `WaitingForSignatures`, `DefinitionReady`, `RunningDKG`, `Complete`,
`LockPresent`, `Failed`. To let an agent in another namespace watch these two ConfigMaps (get/watch by name only,
never Secrets), list its service account in `statusReaders`.

## Launchpad route

```sh
helm upgrade --install my-dv-pod obol/dv-pod -n dv-pod --create-namespace \
  --set mode=launchpad \
  --set network=hoodi \
  --set 'charon.beaconNodeEndpoints[0]=<BEACON_NODE_ENDPOINT>' \
  --set charon.operatorAddress=0xYOUR_OPERATOR_ADDRESS
```

Paste the ENR (above) on the Launchpad when creating or accepting the cluster, and sign with the operator
wallet; the chart never signs. Once every operator has signed, the DKG runs automatically. Set
`charon.dkgSidecar.targetConfigHash` to join one specific definition.

## Direct route (cluster definition)

Collect each operator's ENR (`kubectl get cm <release>-enr ...`), create the definition and share its config hash:

```sh
charon create dkg --network=hoodi --num-validators=1 \
  --fee-recipient-addresses=0x... --withdrawal-addresses=0x... \
  --operator-enrs=enr:-...,enr:-...,enr:-...,enr:-... --publish
```

Each operator then installs with the same definition; no operator address is needed:

```sh
helm upgrade --install my-dv-pod obol/dv-pod -n dv-pod --create-namespace \
  --set mode=definition \
  --set dkg.definition.configHash=0xCONFIG_HASH \
  --set network=hoodi \
  --set 'charon.beaconNodeEndpoints[0]=<BEACON_NODE_ENDPOINT>'
```

Use `dkg.definition.url` for a definition served over HTTPS, or `dkg.definition.configMap` for a file
(`kubectl create configmap cluster-definition --from-file=cluster-definition.json`). The sidecar checks that this
node's ENR is in the definition. Definitions created with operator addresses still need every operator to sign
on the Launchpad; ENR-only definitions don't. See [values-examples/definition.yaml](./values-examples/definition.yaml).

## Obol Stack

In the [Obol Stack](https://obol.org/stack) use the in-cluster beacon node, the Stack's Prometheus and let the
Hermes agent watch progress. [values-examples/obol-stack.yaml](./values-examples/obol-stack.yaml) sets:

- no `charon.beaconNodeEndpoints`: empty means the Stack's node for `network`
  (`http://ethereum-beacon.ethereum-<network>.svc.cluster.local:5052`, created by
  `obol network install ethereum --network <network>`). Set it if your deployment has another id (`obol network list`).
- `serviceMonitor.enabled: true` with `serviceMonitor.labels.release: monitoring`
- `statusReaders: [{namespace: hermes-obol-agent, serviceAccount: hermes}]`
- `charon.builderApi: false`: the Stack runs no MEV-boost (local blocks until Gloas, in-protocol builder bids after it)

```sh
obol helm upgrade --install my-dv-pod obol/dv-pod -n dv-pod --create-namespace \
  -f obol-stack.yaml --set charon.operatorAddress=0xYOUR_OPERATOR_ADDRESS
```

## Import an existing cluster (`mode: lock`)

If you already have private keys and charon artifacts from a central key creation or a DKG ceremony, provide them
to skip the DKG entirely.

#### From a `charon create cluster` output (a `./cluster/nodeN` folder structure)

```
./cluster/
├── node0/
│   ├── charon-enr-private-key
│   ├── cluster-lock.json
│   └── validator_keys/
│       ├── keystore-0.json
│       └── keystore-0.txt
└── ...
```

To deploy node0:
```sh
kubectl create secret generic node0-enr --from-file=cluster/node0/charon-enr-private-key
kubectl create secret generic validator-keys \
  --from-file=cluster/node0/validator_keys/keystore-0.json --from-file=cluster/node0/validator_keys/keystore-0.txt
kubectl create configmap cluster-lock --from-file=cluster/node0/cluster-lock.json

helm install my-dv-pod obol/dv-pod \
  --set mode=lock \
  --set charon.enr.existingSecret.name=node0-enr \
  --set configMaps.clusterLock=cluster-lock \
  --set validatorClient.keystores.secretName=validator-keys
```

#### From a DKG output (a `.charon/` folder)

```sh
kubectl create secret generic my-dv-pod-enr --from-file=.charon/charon-enr-private-key
kubectl create secret generic validator-keys \
  --from-file=.charon/validator_keys/keystore-0.json --from-file=.charon/validator_keys/keystore-0.txt
kubectl create configmap cluster-lock --from-file=.charon/cluster-lock.json

helm install my-dv-pod obol/dv-pod \
  --set mode=lock \
  --set charon.enr.existingSecret.name=my-dv-pod-enr \
  --set configMaps.clusterLock=cluster-lock \
  --set validatorClient.keystores.secretName=validator-keys
```

Also set `network` and `charon.beaconNodeEndpoints` (see [Install the chart](#install-the-chart)). The ENR secret
must be the identity listed in the lock, in the release namespace; the ENR job adds the public `enr` field if missing.

## ENR identity

The ENR private key is the node's charon identity and must never change once it is in a cluster. Its Secret is,
in order: `charon.enr.existingSecret.name`; on upgrade, whatever Secret the release already uses; the legacy shared
`charon-enr-private-key` (`secrets.defaultEnrPrivateKey`) if it exists and no other StatefulSet uses it; otherwise a
new per-release `<fullname>-enr-key`. Two releases in one namespace therefore never share an identity. The ENR job
never overwrites an existing key. Under `helm template`/GitOps (no `lookup`), the job performs the same legacy check
at runtime and copies an existing identity into `<fullname>-enr-key` instead of generating a new one.

## Upgrading from chart < 0.22

- Do not upgrade before `obolnetwork/charon-dkg-sidecar:1.1.0` is published (or pin `charon.dkgSidecar.image.tag`):
  the upgrade restarts the pod, and the sidecar init containers run on every start, even with a lock present.
- Existing installs keep `mode: auto`, which infers the same behaviour as before, and keep their ENR Secret.
- `dkg.runner` now defaults to `charon`. For a node that already has its cluster-lock this changes nothing at
  runtime (all DKG steps skip). For a node still waiting for its DKG, all operators should use the same runner
  and charon version; set `dkg.runner: sidecar` to keep the old flow.
- `charon.builderApi` / `charon.directConnectionEnabled` are booleans; `"true"`/`"false"` strings still work, and
  `"false"` now really disables them (previously any non-empty string enabled MEV flags on the validator client).
- The schema is strict: unknown keys are rejected. Remove typos and keys the chart never had.
- The readiness probe (`/readyz`) is on; the charon Service publishes not-ready addresses so peers and external
  validator clients are unaffected.
- PVCs are retained when the StatefulSet is deleted or scaled down (`persistence.retentionPolicy`).
- The pod no longer mounts a service account token into charon or the validator client.

## Backing up charon-data

After the DKG, `/charon-data` on the `charon-data-<fullname>-0` PVC holds `cluster-lock.json`, `validator_keys/`
(key shares) and `deposit-data*.json`. Back it up off the cluster before activating validators:

```sh
kubectl cp dv-pod/my-dv-pod-0:/charon-data ./my-dv-pod-charon-data -c dv-pod
# Obol Stack: obol kubectl cp dv-pod/my-dv-pod-0:/charon-data ./my-dv-pod-charon-data -c dv-pod
tar czf my-dv-pod-charon-data.tgz my-dv-pod-charon-data && rm -rf my-dv-pod-charon-data   # store encrypted
```

Also keep the ENR Secret (`kubectl get secret <name> -o yaml`). The PVCs and the ENR Secret survive
`helm uninstall`; delete them explicitly only once you no longer need this node's keys.

## Direct peer connections

Peers connect via Obol relays by default. To accept direct connections from outside the cluster, enable
`p2pService` (LoadBalancer or NodePort, see `values.yaml`) and advertise the address with `charon.p2pExternalIp` or
`charon.p2pExternalHostname`. QUIC: set `charon.p2pUdpAddress: 0.0.0.0:3610` and `charon.featureSetEnable: quic`
(alpha in charon v1.11). With `networkPolicy.enabled`, egress to peers and relays on 3610 TCP/UDP is allowed
(`networkPolicy.p2p`).

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
  --set network=<mainnet|hoodi|sepolia> \
  --set='charon.beaconNodeEndpoints[0]=<BEACON_NODE_ENDPOINT>' \
  --set='charon.operatorAddress=<YOUR_OPERATOR_ADDRESS>'
```

`charon.beaconNodeEndpoints` must point at a synced consensus client for `network`. Left empty, it defaults to the
[Obol Stack](https://obol.org/stack)'s node for `network` (`http://ethereum-beacon.ethereum-<network>.svc.cluster.local:5052`);
outside the Stack, always set it.

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
  --set mode=lock \
  --set configMaps.clusterLock=cluster-lock \
  --set validatorClient.keystores.secretName=validator-keys \
  --set validatorClient.type=prysm
```

> [!NOTE]
> By choosing the Prysm VC you accept their [Terms of Use](https://github.com/OffchainLabs/prysm/blob/develop/TERMS_OF_SERVICE.md); the chart passes `--accept-terms-of-use`.

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
  --set mode=lock \
  --set validatorClient.keystores.secretName=validator-keys \
  --set configMaps.clusterLock=my-cluster-lock
```

#### Option 2: DKG-Generated Keystores (Automatic)

When running DKG through the chart, keystores are automatically generated and imported to the validator client. The import process handles the specific directory structure required by each validator client:

- **Lighthouse**: Keystores in `/validator-data/validators/`, passwords in `/validator-data/secrets/`
- **Lodestar**: Restructured with pubkey directories under `/validator-data/keystores/`
- **Teku**: Keystores in `/validator-data/keys/`, passwords in `/validator-data/passwords/`
- **Prysm**: Imported into a wallet in `/validator-data/wallet/`
- **Nimbus**: Similar to Lighthouse structure

## Namespace Requirements

### ENR Secret Management

The ENR (Ethereum Node Record) secret **MUST** be created in the same namespace as the Helm release. The chart's ENR job will only check for existing secrets within its own namespace (`.Release.Namespace`).

**Common Pitfall**: Creating the ENR secret in a different namespace (e.g., `dv-pod`) and then installing the chart in another namespace (e.g., `default`) will result in the ENR job generating a new ENR for the release instead of using yours.

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
--beacon-node-api-endpoint="http://<RELEASE_NAME>.<NAMESPACE>.svc.cluster.local:3600"
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

In this case, provide the lock hash instead:

1. Extract the lock_hash from your cluster-lock.json:
   ```sh
   LOCK_HASH=$(jq -r '.lock_hash' cluster-lock.json)
   echo $LOCK_HASH
   ```

2. Install the chart with the lockHash value:
   ```sh
   helm install my-dv-pod obol/dv-pod \
     --set mode=lockHash \
     --set charon.lockHash=$LOCK_HASH \
     --set validatorClient.keystores.secretName=validator-keys
   ```

The DKG sidecar will use the lock hash to fetch the full cluster lock from the Obol API.

## Uninstall the Chart
To uninstall and delete the `dv-pod` release:
```sh
helm uninstall dv-pod -n dv-pod
```
The command removes the Kubernetes components associated with the chart and deletes the release. The PVCs
(`charon-data-*`, `validator-data-*`), the ENR Secret and the `<fullname>-enr` ConfigMap are kept on purpose; see
[Backing up charon-data](#backing-up-charon-data) before deleting them.

## Full Chart Values Reference

## Values

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| affinity | object | `{}` | Affinity for pod assignment # ref: https://kubernetes.io/docs/concepts/configuration/assign-pod-node/#affinity-and-anti-affinity # # Example: # affinity: #   podAntiAffinity: #     requiredDuringSchedulingIgnoredDuringExecution: #     - labelSelector: #         matchExpressions: #         - key: app.kubernetes.io/name #           operator: In #           values: #           - charon #       topologyKey: kubernetes.io/hostname # |
| centralMonitoring | object | `{"enabled":false,"promEndpoint":"https://vm.monitoring.gcp.obol.tech/write","token":""}` | Central Monitoring |
| centralMonitoring.enabled | bool | `false` | Specifies whether central monitoring should be enabled |
| centralMonitoring.promEndpoint | string | `"https://vm.monitoring.gcp.obol.tech/write"` | https endpoint to obol central prometheus |
| centralMonitoring.token | string | `""` | The authentication token to the central prometheus |
| charon.beaconNodeEndpoints | list | `[]` | Beacon node endpoints (your own synced consensus client's beacon API). Empty means the Obol Stack's node for `network`: http://ethereum-beacon.ethereum-<network>.svc.cluster.local:5052, which is what `obol network install ethereum --network <network>` creates (its first deployment's id is the network name). Set this outside the Stack, or for a Stack deployment with another id (`obol network list`). All beacon nodes specified here will be called for every charon request, if you want to leverage fallback behaviour place secondary beacon nodes in charon.fallbackBeaconNodeEndpoints[] |
| charon.beaconNodeHeaders | string | `""` | Beacon node authentication headers WARNING: These headers will be sent to ALL beacon nodes, which could leak credentials Format: "Authorization=Basic <base64_encoded_credentials>" To generate: echo -n "username:password" | base64 Example: "Authorization=Basic am9objpkb2U=" |
| charon.beaconNodeHeadersSecretKey | string | `"headers"` | Optional: Key within the charon.beaconNodeHeaders secret to read from |
| charon.beaconNodeHeadersSecretName | string | `""` | Optional: Name of the secret containing beacon node headers Use this for secure credential storage instead of beaconNodeHeaders The secret should contain a key specified by charon.beaconNodeHeadersSecretKey |
| charon.builderApi | bool | `true` | Enables the builder api (MEV) for validator proposals. The Builder API must also be enabled on your beacon node client(s). The Beacon node must either be connected to a mev sidecar or a mev relay to access the builder network. More documentation about MEV can be found [here](https://docs.obol.org/advanced-and-troubleshooting/advanced/enable-mev). Accepts a boolean; the strings "true"/"false" from older values files are still understood. |
| charon.directConnectionEnabled | bool | `true` | If enabled, it will set p2pExternalHostname value to the pod name and enable direct connection between cluster nodes. This is useful for deployments where pods can directly communicate with each other. Accepts a boolean; the strings "true"/"false" from older values files are still understood. |
| charon.dkgSidecar | object | `{"apiEndpoint":"https://api.obol.tech","enabled":true,"image":{"pullPolicy":"IfNotPresent","repository":"obolnetwork/charon-dkg-sidecar","tag":"1.1.0"},"initialRetryDelaySeconds":10,"maxRetryDelaySeconds":300,"pageLimit":10,"resources":{"limits":{"cpu":"200m","memory":"256Mi"},"requests":{"cpu":"50m","memory":"128Mi"}},"retryDelayFactor":2,"retryDelaySeconds":10,"serviceAccount":{"create":true},"targetConfigHash":""}` | DKG sidecar init container (obolnetwork/charon-dkg-sidecar). It prepares participation according to `mode`: exits at once if /charon-data/cluster-lock.json exists (or is mounted from `configMaps.clusterLock`), fetches the lock for `charon.lockHash`, or obtains a fully signed cluster definition (Launchpad polling by operator address, or `dkg.definition`). With `dkg.runner: charon` the DKG itself then runs in the `charon-dkg` init container. It also writes progress to the "<fullname>-dkg-status" ConfigMap (`dkg.status.enabled`). Disable it only to bring your own cluster-lock and key shares (`mode: lock`). |
| charon.dkgSidecar.apiEndpoint | string | `"https://api.obol.tech"` | API endpoint for the Obol network to fetch cluster definitions |
| charon.dkgSidecar.image.repository | string | `"obolnetwork/charon-dkg-sidecar"` | Image repository for the DKG sidecar |
| charon.dkgSidecar.image.tag | string | `"1.1.0"` | DKG sidecar image tag. 1.1.0 implements DKG_RUNNER/DEFINITION_SOURCE/status reporting. |
| charon.dkgSidecar.initialRetryDelaySeconds | int | `10` | Initial delay in seconds before the first retry of a polling cycle. |
| charon.dkgSidecar.maxRetryDelaySeconds | int | `300` | Maximum delay in seconds for exponential backoff between polling cycles. |
| charon.dkgSidecar.pageLimit | int | `10` | Page limit for API calls when fetching cluster definitions |
| charon.dkgSidecar.resources | object | `{"limits":{"cpu":"200m","memory":"256Mi"},"requests":{"cpu":"50m","memory":"128Mi"}}` | Resources for the cluster poller init container |
| charon.dkgSidecar.retryDelayFactor | int | `2` | Factor by which the retry delay increases after each polling cycle (e.g., 2 for doubling). |
| charon.dkgSidecar.retryDelaySeconds | int | `10` | Delay in seconds between polling retries |
| charon.dkgSidecar.serviceAccount | object | `{"create":true}` | Service account settings for test pods |
| charon.dkgSidecar.targetConfigHash | string | `""` | Launchpad mode only: join just this cluster definition (optional). Must be a valid 32-byte hex hash with 0x prefix (66 characters total). Example: "0x7f0fd29abb11674b4e61000de26bff3600237aab0402427bd1409756665c2115" |
| charon.enr.existingSecret | object | `{"name":"","privateKeyDataKey":"charon-enr-private-key","publicKeyDataKey":"enr"}` | Point to an existing Kubernetes secret that holds the ENR private key. The ENR job never overwrites it; it only adds a missing public `enr` field. NOTE: If not set, see `secrets` above for how the secret name is chosen. |
| charon.enr.existingSecret.privateKeyDataKey | string | `"charon-enr-private-key"` | Key in the secret's 'data' field holding the private key hex string |
| charon.enr.existingSecret.publicKeyDataKey | string | `"enr"` | Key in the secret's 'data' field holding the public ENR string |
| charon.enr.generate | object | `{"annotations":{},"enabled":true,"kubectlImage":{"pullPolicy":"IfNotPresent","repository":"bitnamisecure/kubectl","tag":"latest@sha256:999d5eb28f404b45f15117f2a110ff23c6164f76edac261d75d783b6e88252b7"},"nodeSelector":{}}` | Enable automatic generation of an ENR private key. Only used if 'privateKey' and 'existingSecret.name' are not provided. The generated key will be stored in a secret with data keys 'charon-enr-private-key' and 'enr'. |
| charon.enr.generate.annotations | object | `{}` | Annotations to add to the ENR generation job |
| charon.enr.generate.kubectlImage | object | `{"pullPolicy":"IfNotPresent","repository":"bitnamisecure/kubectl","tag":"latest@sha256:999d5eb28f404b45f15117f2a110ff23c6164f76edac261d75d783b6e88252b7"}` | Image to use for kubectl operations within the ENR generation job This image must contain a compatible kubectl binary and a POSIX shell. bitnamisecure only publishes `latest`, so it is pinned by digest. |
| charon.enr.generate.nodeSelector | object | `{}` | Node selector for the ENR generation job The job generates the key with the main charon image (`image`). |
| charon.enr.privateKey | string | `""` | Provide the ENR private key directly (hex format, e.g., 0x...). The ENR job uses it to create the ENR secret (passed via a short-lived hook Secret, not the Job spec). Ignored if the ENR secret already exists, so an existing identity is never overwritten. Prefer 'existingSecret': values are stored in the Helm release. |
| charon.enrJob.enabled | bool | `true` | Enable or disable the Kubernetes Job that generates/manages the ENR. Note: This is typically not needed as the job automatically detects existing secrets. The job will check if the ENR secret already exists and skip generation if found. Only set to false for advanced use cases where you need to completely disable the job. |
| charon.executionClientRpcEndpoint | string | `""` | Optional: Execution client RPC endpoint URL (e.g., your Ethereum execution client) Note: Charon currently only supports a single execution endpoint This is only needed if an operator in the cluster uses a smart contract wallet for an operator signature. If that does not apply to this cluster, this field can be left unset. |
| charon.fallbackBeaconNodeEndpoints | list | `[]` | Fallback beacon node endpoints (optional) These will be used if the primary beaconNodeEndpoints are unavailable. If empty and publicnodeFallback is true, the publicnode.com beacon API for `network` is used. |
| charon.featureSet | string | `"stable"` | Minimum feature set to enable by default: alpha, beta, or stable. Warning: modify at own risk. (default "stable") |
| charon.featureSetDisable | string | `""` | Comma-separated list of features to disable, overriding the default minimum feature set. |
| charon.featureSetEnable | string | `""` | Comma-separated list of features to enable, overriding the default minimum feature set. |
| charon.fetchFeeRecipientUpdates | bool | `true` | Enables polling the Obol API for signed fee recipient update messages that override the currently configured fee recipient. |
| charon.lockFile | string | `"/charon-data/cluster-lock.json"` | The path on the pod to the cluster lock file that definesthe distributed validator cluster. (default "/charon-data/cluster-lock.json") |
| charon.lockHash | string | `""` | Cluster lock hash for large cluster-lock files (>1MB); used by `mode: lockHash`. The DKG sidecar fetches the full cluster-lock from the Obol API using this hash Extract the hash from a cluster-lock.json using: `jq -r '.lock_hash' cluster-lock.json` Alternative to providing the full cluster-lock.json file via the configMaps.clusterLock value |
| charon.logFormat | string | `"json"` | Log format; console, logfmt or json (default "json") |
| charon.logLevel | string | `"info"` | Log level; debug, info, warn or error (default "info") |
| charon.lokiAddresses | string | `""` | Enables sending of logfmt structured logs to these Loki log aggregation server addresses. This is in addition to normal stderr logs. |
| charon.lokiService | string | `""` | Service label sent with logs to Loki. |
| charon.monitoringAddress | string | `"0.0.0.0:3620"` | Listening address (ip and port) for the monitoring API (prometheus, pprof). (default "127.0.0.1:3620") |
| charon.nickname | string | `""` | The nickname this Charon appears as in monitoring and its peer's logs. Maximum 32 characters. |
| charon.noVerify | bool | `false` | Disables cluster definition and lock file verification. |
| charon.operatorAddress | string | `""` | The Ethereum address of this operator (the wallet that signs the Launchpad invite). Required in `mode: launchpad` (and `mode: auto` without a lock or definition); not needed for `definition`, `lock` or `lockHash`. |
| charon.p2pAllowlist | string | `""` | Comma-separated list of CIDR subnets for allowing only certain peer connections. Example: 192.168.0.0/16 would permit connections to peers on your local network only. The default is to accept all connections. |
| charon.p2pDenylist | string | `""` | Comma-separated list of CIDR subnets for disallowing certain peer connections. Example: 192.168.0.0/16 would disallow connections to peers on your local network. The default is to accept all connections. |
| charon.p2pDisableReuseport | string | `""` | Disables TCP port reuse for outgoing libp2p connections. |
| charon.p2pExternalHostname | string | `""` | The DNS hostname advertised by libp2p. This may be used to advertise an external DNS. |
| charon.p2pExternalIp | string | `""` | The IP address advertised by libp2p. This may be used to advertise an external IP. |
| charon.p2pRelays | string | `""` | Comma-separated list of libp2p relay URLs or multiaddrs. Default list is provided by libp2p and may change over time |
| charon.p2pTcpAddress | string | `"0.0.0.0:3610"` | Comma-separated list of listening TCP addresses (ip and port) for libP2P traffic. Empty default doesn't bind to local port therefore only supports outgoing connections. |
| charon.p2pUdpAddress | string | `""` | Comma-separated list of listening UDP addresses (ip and port) for libp2p QUIC traffic, e.g. "0.0.0.0:3610". Empty (default) disables UDP. QUIC is an alpha feature in charon v1.11: also set `featureSetEnable: quic`. Adds a `p2p-udp` container port (and a UDP port on `p2pService`) on the parsed port. |
| charon.privateKeyFile | string | `"/data/charon-enr-private-key"` | Path within the Charon container where the ENR private key file will be mounted. |
| charon.publicnodeFallback | bool | `true` | When fallbackBeaconNodeEndpoints is empty, fall back to the public publicnode.com beacon API matching `network`. Set to false to run with no fallback beacon node. |
| charon.validatorApiAddress | string | `"0.0.0.0:3600"` | Listening address (ip and port) for validator-facing traffic proxying the beacon-node API. (default "127.0.0.1:3600") |
| clusterThreshold | string | `""` | Maximum number of pods that can be unavailable for cluster threshold Used in pod disruption budget when minAvailable is not specified |
| configMaps | object | `{"clusterLock":""}` | Kubernetes configMaps names for non-sensitive configuration data. |
| configMaps.clusterLock | string | `""` | Name of the ConfigMap containing the cluster-lock.json file (`mode: lock`). Set this to the name of an existing ConfigMap to skip the DKG process. Example: kubectl create configmap cluster-lock --from-file=.charon/cluster-lock.json Then set: clusterLock: "cluster-lock" If not set or if the ConfigMap doesn't exist, the DKG process will run. NOTE: For large cluster-lock files (>1MB), use charon.lockHash instead clusterLock: "cluster-lock" |
| containerSecurityContext | object | See `values.yaml` | The security context for containers |
| dkg | object | `{"definition":{"configHash":"","configMap":"","configMapKey":"cluster-definition.json","url":""},"extraArgs":[],"publish":true,"resources":{"limits":{"cpu":"1000m","memory":"1Gi"},"requests":{"cpu":"100m","memory":"256Mi"}},"retryDelaySeconds":10,"runner":"charon","status":{"enabled":true},"timeout":""}` | DKG (distributed key generation) settings. See `mode` for how the cluster definition is found. |
| dkg.definition | object | `{"configHash":"","configMap":"","configMapKey":"cluster-definition.json","url":""}` | Cluster definition for `mode: definition` (or `mode: auto`). Set exactly one source. |
| dkg.definition.configMap | string | `""` | Name of a ConfigMap in the release namespace holding the cluster-definition.json. Example: kubectl create configmap cluster-definition --from-file=cluster-definition.json |
| dkg.definition.configMapKey | string | `"cluster-definition.json"` | Key within `dkg.definition.configMap` holding the definition. |
| dkg.definition.url | string | `""` | HTTPS URL serving the cluster-definition.json. |
| dkg.extraArgs | list | `[]` | Extra arguments for `charon dkg`. Runner `charon` only. |
| dkg.resources | object | `{"limits":{"cpu":"1000m","memory":"1Gi"},"requests":{"cpu":"100m","memory":"256Mi"}}` | Resources for the `charon-dkg` init container. |
| dkg.retryDelaySeconds | int | `10` | Seconds to wait between `charon dkg` attempts while peers come online. Runner `charon` only. |
| dkg.runner | string | `"charon"` | Who runs `charon dkg`: - `charon` (default): the sidecar only fetches/validates the definition and exits; a `charon-dkg` init   container then runs `charon dkg` with this chart's charon `image`, so the DKG always uses the same   charon version as the node. A `dkg-report` init container records the result. - `sidecar`: legacy; the sidecar runs the charon binary bundled in its own image. |
| dkg.status.enabled | bool | `true` | Have the sidecar publish DKG progress to the ConfigMap "<fullname>-dkg-status" (keys: phase, message, updatedAt, enr, operatorAddress, definitionSource, configHash, clusterName, signatures, lockHash, numValidators, sidecarVersion), so agents can watch it without reading Secrets or logs. Creates a Role allowing only get/patch on that ConfigMap; the service account token is mounted only into the sidecar containers. Needs `serviceAccount.enabled` and `rbac.enabled`. |
| dkg.timeout | string | `""` | Timeout for one `charon dkg` attempt, e.g. "5m" (empty: charon default, 2m). Runner `charon` only. |
| fullnameOverride | string | `""` | Provide a name to substitute for the full names of resources |
| global | object | `{"annotations":{}}` | Global configuration that can be referenced across the chart Used for test configurations and shared settings |
| global.annotations | object | `{}` | Global annotations applied to resources |
| image | object | `{"pullPolicy":"IfNotPresent","repository":"obolnetwork/charon","tag":"v1.11.0"}` | Charon image repository, pull policy, and tag version |
| imagePullSecrets | list | `[]` | Credentials to fetch images from private registry # ref: https://kubernetes.io/docs/tasks/configure-pod-container/pull-image-private-registry/ |
| livenessProbe | object | `{"enabled":false,"httpGet":{"path":"/livez","port":3620},"initialDelaySeconds":10,"periodSeconds":5}` | Configure liveness probes # ref: https://kubernetes.io/docs/tasks/configure-pod-container/configure-liveness-readiness-startup-probes/ |
| livenessProbe.httpGet.port | int | `3620` | Port for liveness probe HTTP checks |
| mode | string | `"auto"` | How this node joins its distributed validator cluster: - `auto` (default): infer from the values set, as charts < 0.22 did:   `configMaps.clusterLock` -> lock, `charon.lockHash` -> lockHash, any `dkg.definition.*` -> definition,   otherwise launchpad. - `launchpad`: Launchpad invite. The DKG sidecar polls the Obol API for a definition containing this   node's ENR under `charon.operatorAddress` (required), waits for every operator to sign, then runs the DKG. - `definition`: direct route. The cluster definition (from `charon create dkg`) is given by exactly one of   `dkg.definition.configHash`, `.url` or `.configMap`. No operator address needed; this node's ENR must be   one of the definition's operators. - `lock`: import an existing cluster; `configMaps.clusterLock` is required. No DKG. - `lockHash`: like `lock` for large locks; `charon.lockHash` is required and the lock is fetched from the Obol API. |
| nameOverride | string | `""` | Provide a name in place of charon for `app:` labels |
| network | string | `"mainnet"` | Network name for the Ethereum network Supported values: mainnet, sepolia, hoodi The chainId is automatically derived from the network name |
| networkPolicy | object | `{"beaconNodes":{"enabled":true,"ipBlock":{},"namespaceSelector":{},"podSelector":{},"port":""},"customEgress":[],"customIngress":[],"enabled":false,"kubeApi":{"cidr":"0.0.0.0/0","enabled":true,"ports":[443,6443]},"monitoring":{"enabled":true,"extraFrom":[],"namespaceSelector":{},"podSelector":{}},"obolApi":{"cidr":"0.0.0.0/0","enabled":true,"except":[]},"p2p":{"allowInbound":false,"cidr":"0.0.0.0/0","enabled":true,"except":[],"ports":[3610]},"validatorClientNamespaceSelector":{},"validatorClientSelector":{}}` | NetworkPolicy configuration for pod network isolation |
| networkPolicy.beaconNodes | object | `{"enabled":true,"ipBlock":{},"namespaceSelector":{},"podSelector":{},"port":""}` | Beacon node configuration |
| networkPolicy.beaconNodes.enabled | bool | `true` | Enable egress to beacon nodes |
| networkPolicy.beaconNodes.ipBlock | object | `{}` | IP block for external beacon nodes |
| networkPolicy.beaconNodes.namespaceSelector | object | `{}` | Namespace selector for beacon nodes |
| networkPolicy.beaconNodes.podSelector | object | `{}` | Pod selector for beacon nodes |
| networkPolicy.beaconNodes.port | string | `""` | Port for beacon node connections (leave empty for any port) |
| networkPolicy.customEgress | list | `[]` | Custom egress rules to add |
| networkPolicy.customIngress | list | `[]` | Custom ingress rules to add |
| networkPolicy.enabled | bool | `false` | Enable NetworkPolicy to restrict network traffic |
| networkPolicy.kubeApi | object | `{"cidr":"0.0.0.0/0","enabled":true,"ports":[443,6443]}` | Kubernetes API egress for the DKG sidecar's status ConfigMap (only rendered when dkg.status is active) |
| networkPolicy.kubeApi.cidr | string | `"0.0.0.0/0"` | CIDR of the API server endpoints |
| networkPolicy.kubeApi.ports | list | `[443,6443]` | API server ports (443 for the kubernetes Service, 6443 for typical endpoints) |
| networkPolicy.monitoring | object | `{"enabled":true,"extraFrom":[],"namespaceSelector":{},"podSelector":{}}` | Monitoring configuration |
| networkPolicy.monitoring.enabled | bool | `true` | Enable access from monitoring tools |
| networkPolicy.monitoring.extraFrom | list | `[]` | Additional NetworkPolicyPeers allowed to reach port 3620 (metrics, /readyz), e.g. an agent namespace. Only applied when podSelector or namespaceSelector is set (otherwise 3620 is open to all sources). Obol Stack Hermes: [{namespaceSelector: {matchLabels: {kubernetes.io/metadata.name: hermes-obol-agent}}}] |
| networkPolicy.monitoring.namespaceSelector | object | `{}` | Namespace selector for monitoring namespace |
| networkPolicy.monitoring.podSelector | object | `{}` | Pod selector for monitoring tools (e.g., Prometheus) |
| networkPolicy.obolApi | object | `{"cidr":"0.0.0.0/0","enabled":true,"except":[]}` | Obol API configuration |
| networkPolicy.obolApi.cidr | string | `"0.0.0.0/0"` | CIDR block for Obol API access |
| networkPolicy.obolApi.enabled | bool | `true` | Enable egress to Obol API for DKG |
| networkPolicy.obolApi.except | list | `[]` | IP ranges to exclude |
| networkPolicy.p2p | object | `{"allowInbound":false,"cidr":"0.0.0.0/0","enabled":true,"except":[],"ports":[3610]}` | Charon P2P traffic outside the cluster (peers and relays) |
| networkPolicy.p2p.allowInbound | bool | `false` | Also allow inbound peers from `cidr` (always on when p2pService is enabled) |
| networkPolicy.p2p.cidr | string | `"0.0.0.0/0"` | CIDR for external peers and relays |
| networkPolicy.p2p.enabled | bool | `true` | Allow egress to peers/relays on `ports` (TCP and UDP) |
| networkPolicy.p2p.except | list | `[]` | IP ranges to exclude |
| networkPolicy.p2p.ports | list | `[3610]` | Peer/relay libp2p ports |
| networkPolicy.validatorClientNamespaceSelector | object | `{}` | Namespace selector for validator client access |
| networkPolicy.validatorClientSelector | object | `{}` | Selector for validator client pods that can access the validator API |
| nodeSelector | object | `{}` | Node labels for pod assignment # ref: https://kubernetes.io/docs/user-guide/node-selection/ |
| p2pService | object | `{"annotations":{},"enabled":false,"externalTrafficPolicy":"Local","loadBalancerIP":"","loadBalancerSourceRanges":[],"nodePorts":{"tcp":null,"udp":null},"port":3610,"type":"LoadBalancer"}` | Optional Service exposing charon's libp2p port outside the cluster, so peers can connect directly instead of via relays. Disabled by default (relays work without it). With LoadBalancer, set `charon.p2pExternalIp` (or `p2pExternalHostname`) to the load balancer address. With NodePort, peers reach the node port, so charon must listen and advertise on that same port: e.g. `nodePorts.tcp: 31610`, `charon.p2pTcpAddress: 0.0.0.0:31610`, `service.ports.p2pTcp.targetPort: 31610`, and `charon.p2pExternalIp: <node public IP>`. UDP (QUIC) is added when `charon.p2pUdpAddress` is set. |
| p2pService.annotations | object | `{}` | Service annotations (e.g. cloud load balancer settings) |
| p2pService.externalTrafficPolicy | string | `"Local"` | Cluster or Local. Local preserves the peer's source IP and avoids a second hop. |
| p2pService.loadBalancerIP | string | `""` | loadBalancerIP for providers that support it |
| p2pService.loadBalancerSourceRanges | list | `[]` | Restrict which source ranges may reach a LoadBalancer |
| p2pService.nodePorts | object | `{"tcp":null,"udp":null}` | Fixed node ports when type is NodePort (null: allocated by Kubernetes) |
| p2pService.port | int | `3610` | Service port for libp2p TCP (and UDP) |
| p2pService.type | string | `"LoadBalancer"` | NodePort or LoadBalancer |
| persistence | object | `{"accessModes":["ReadWriteOnce"],"annotations":{},"enabled":true,"retentionPolicy":{"whenDeleted":"Retain","whenScaled":"Retain"},"size":"1Gi","validatorDataSize":"500Mi"}` | Persistence configuration for DKG artifacts and charon data |
| persistence.accessModes | list | `["ReadWriteOnce"]` | Access modes for the PVC. Must be a list. Default: ["ReadWriteOnce"]. |
| persistence.annotations | object | `{}` | Annotations for the PVC Example: annotations: {"volume.beta.kubernetes.io/storage-class": "fast"} |
| persistence.enabled | bool | `true` | Enable persistence using a PersistentVolumeClaim. |
| persistence.retentionPolicy | object | `{"whenDeleted":"Retain","whenScaled":"Retain"}` | StatefulSet persistentVolumeClaimRetentionPolicy. Retain keeps charon-data (cluster-lock, key shares) and validator-data (slashing protection) when the StatefulSet is deleted or scaled down (Kubernetes >= 1.27). Set to null to omit the field. |
| persistence.size | string | `"1Gi"` | Size of the PVC for charon-data. |
| persistence.validatorDataSize | string | `"500Mi"` | Size of the PVC for validator-data. Validator data includes slashing protection DB and other validator state. NOTE: Validator data ALWAYS uses persistent storage to prevent slashing, even if persistence.enabled is false for charon-data. |
| podAnnotations | object | `{"pod-security.kubernetes.io/audit":"baseline","pod-security.kubernetes.io/audit-version":"latest","pod-security.kubernetes.io/enforce":"baseline","pod-security.kubernetes.io/enforce-version":"latest","pod-security.kubernetes.io/warn":"baseline","pod-security.kubernetes.io/warn-version":"latest"}` | Pod annotations |
| podDisruptionBudget | object | `{"enabled":true,"minAvailable":""}` | Enable pod disruption budget # ref: https://kubernetes.io/docs/tasks/run-application/configure-pdb |
| priorityClassName | string | `""` | Used to assign priority to pods # ref: https://kubernetes.io/docs/concepts/configuration/pod-priority-preemption/ |
| rbac | object | `{"clusterRules":[],"enabled":true,"name":"","rules":[]}` | RBAC configuration. # ref: https://kubernetes.io/docs/reference/access-authn-authz/rbac/ |
| rbac.clusterRules | list | `[]` | ClusterRole rules for the pod's service account. None of the chart's containers call the Kubernetes API, so this is empty by default; the ClusterRole is only created when rules are set. |
| rbac.enabled | bool | `true` | Specifies whether RBAC resources are to be created |
| rbac.name | string | `""` | The name of the cluster role to use. If not set and create is true, a name is generated using the fullname template |
| rbac.rules | list | `[]` | Role rules for the pod's service account. Empty by default; the Role is only created when rules are set. |
| readinessProbe | object | `{"enabled":true,"failureThreshold":3,"httpGet":{"path":"/readyz","port":3620},"initialDelaySeconds":10,"periodSeconds":10,"timeoutSeconds":5}` | Readiness probe on charon's /readyz (beacon node synced, peers and validator client connected). Readiness only marks the pod Ready; Services publish not-ready addresses, so peers and an external VC can still connect while charon gets ready. There is deliberately no liveness probe by default: a node that is up but waiting for peers or a syncing beacon node must not be restarted. Init containers (DKG) run first. # ref: https://kubernetes.io/docs/tasks/configure-pod-container/configure-liveness-readiness-startup-probes/ |
| readinessProbe.httpGet.port | int | `3620` | Port for readiness probe HTTP checks |
| resources | object | `{"limits":{"cpu":"2000m","memory":"4Gi"},"requests":{"cpu":"1000m","memory":"2Gi"}}` | Pod resources limits and requests |
| secrets | object | `{"defaultEnrPrivateKey":"charon-enr-private-key"}` | Kubernetes secrets names. The ENR private key (this node's charon identity) lives in, in order of precedence: 1. `charon.enr.existingSecret.name`, if set; 2. on upgrade, the Secret this release's StatefulSet already mounts (an identity is never replaced); 3. `secrets.defaultEnrPrivateKey` ("charon-enr-private-key") if it exists in the namespace and no other    StatefulSet uses it (a pre-created Secret for importing a cluster, or an install from chart < 0.22); 4. otherwise a per-release Secret "<fullname>-enr-key" (e.g. "my-dv-pod-enr-key"), created by the ENR job. Two releases in one namespace therefore never share an identity. The public ENR is also published to the ConfigMap "<fullname>-enr" (key `enr`), so it can be read without access to Secrets. |
| secrets.defaultEnrPrivateKey | string | `"charon-enr-private-key"` | Legacy shared ENR secret name, adopted if it exists and is not used by another release. IMPORTANT: only the release namespace is checked. Set to "" to never adopt it. |
| securityContext | object | See `values.yaml` | The security context for pods fsGroup lets the non-root containers (uid 1000) write to volumes provisioned root-owned. Note: do not set runAsNonRoot here; the prepare-validator-data init container runs as root to set file permissions. |
| service | object | `{"clusterIP":"None","ports":{"monitoring":{"name":"monitoring","port":3620,"protocol":"TCP","targetPort":3620},"p2pTcp":{"name":"p2p-tcp","port":3610,"protocol":"TCP","targetPort":3610},"validatorApi":{"name":"validator-api","port":3600,"protocol":"TCP","targetPort":3600}},"publishNotReadyAddresses":true}` | Charon service ports |
| service.clusterIP | string | `"None"` | Headless service to create DNS for each statefulset instance |
| service.publishNotReadyAddresses | bool | `true` | Publish DNS records for pods that are not Ready yet. Peers resolve each other's <pod>.<fullname>.<namespace>.svc names during the DKG and before charon is ready. |
| serviceAccount | object | `{"annotations":{},"enabled":true,"name":"","nameTest":""}` | Service account # ref: https://kubernetes.io/docs/tasks/configure-pod-container/configure-service-account/ |
| serviceAccount.annotations | object | `{}` | Annotations to add to the service account |
| serviceAccount.enabled | bool | `true` | Specifies whether a service account should be created |
| serviceAccount.name | string | `""` | The name of the service account to use. If not set, a name is generated using the default template |
| serviceAccount.nameTest | string | `""` | The name of the service account to use for test pods. If not set, uses the main service account |
| serviceMonitor | object | `{"annotations":{},"enabled":false,"interval":"1m","labels":{},"namespace":"","path":"/metrics","relabelings":[],"scheme":"http","scrapeTimeout":"30s","tlsConfig":{}}` | Prometheus Service Monitor # ref: https://github.com/coreos/prometheus-operator |
| serviceMonitor.annotations | object | `{}` | Additional ServiceMonitor annotations |
| serviceMonitor.enabled | bool | `false` | If true, a ServiceMonitor CRD is created for a prometheus operator. https://github.com/coreos/prometheus-operator TODO: SWITCH BACK TO ON FOR PRODUCTION |
| serviceMonitor.interval | string | `"1m"` | ServiceMonitor scrape interval |
| serviceMonitor.labels | object | `{}` | Additional ServiceMonitor labels |
| serviceMonitor.namespace | string | `""` | Alternative namespace for ServiceMonitor |
| serviceMonitor.path | string | `"/metrics"` | Path to scrape |
| serviceMonitor.relabelings | list | `[]` | ServiceMonitor relabelings |
| serviceMonitor.scheme | string | `"http"` | ServiceMonitor scheme |
| serviceMonitor.scrapeTimeout | string | `"30s"` | ServiceMonitor scrape timeout |
| serviceMonitor.tlsConfig | object | `{}` | ServiceMonitor TLS configuration |
| statusReaders | list | `[]` | Grant read access to this release's public ConfigMaps ("<fullname>-dkg-status" and "<fullname>-enr") to service accounts outside the release, e.g. an agent watching DKG progress. Renders a Role with get/watch restricted to those two names (no list: Kubernetes can't restrict list by name, so readers fetch them by name) and a RoleBinding. Never grants access to Secrets. Obol Stack (Hermes agent): [{namespace: hermes-obol-agent, serviceAccount: hermes}] |
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
| validatorClient.enabled | bool | `true` | Enable the validator client container If you want to use an externally managed validator client. Set this to false, and set your external validator to communicate with the 'validator-api' service created by this chart as if it were a beacon node API. |
| validatorClient.image | object | `{"pullPolicy":"IfNotPresent","repository":"","tag":""}` | Image configuration for validator client Repository and tag will be auto-selected based on validator client type if not specified |
| validatorClient.keystores | object | `{"secretName":""}` | Validator keystores configuration |
| validatorClient.keystores.secretName | string | `""` | Name of the Secret containing validator keystores If provided, skip keystore generation and use existing keys The secret should contain keystore-*.json and keystore-*.txt files Example: kubectl create secret generic validator-keys --from-file=keystore-0.json --from-file=keystore-0.txt secretName: "validator-keys" |
| validatorClient.resources | object | `{"limits":{"cpu":"1000m","memory":"2Gi"},"requests":{"cpu":"500m","memory":"1Gi"}}` | Resource limits and requests for validator client |
| validatorClient.type | string | `"lighthouse"` | Type of validator client to use Options: lighthouse, teku, prysm, nimbus, lodestar |