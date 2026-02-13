
Aztec Node
===========

![Version: 1.0.0](https://img.shields.io/badge/Version-1.0.0-informational?style=flat-square) ![Type: application](https://img.shields.io/badge/Type-application-informational?style=flat-square) ![AppVersion: 3.0.3](https://img.shields.io/badge/AppVersion-3.0.3-informational?style=flat-square)

A Helm chart for deploying an Aztec node

## Values

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| certificate.domains | list | `[]` |  |
| certificate.enabled | bool | `false` |  |
| customNetwork | object | `{"feeAssetHandlerContractAddress":null,"l1ChainId":null,"registryContractAddress":null,"slashFactoryAddress":null}` | Custom network - (not recommended) - Only for custom testnet usecases Must have deployed your own protocol contracts first |
| fullnameOverride | string | `""` | Overrides the chart computed fullname |
| hostNetwork | bool | `true` | Use host network - provides best P2P performance by binding directly to node's network This is the recommended configuration for Aztec nodes |
| image | object | `{"pullPolicy":"IfNotPresent","repository":"aztecprotocol/aztec","tag":"3.0.3"}` | Image to use for the container |
| image.pullPolicy | string | `"IfNotPresent"` | Container pull policy |
| image.repository | string | `"aztecprotocol/aztec"` | Image repository |
| image.tag | string | `"3.0.3"` | Image tag |
| initContainers | list | `[]` | Additional init containers |
| nameOverride | string | `""` | Overrides the chart name |
| network | string | `nil` | Network name - this is a predefined network - testnet, devnet |
| networkName | string | `"staging-public"` | Network identifier used in resource naming (l2-{role}-node-{networkName}-{component}) This appears in service/statefulset names for easy identification |
| node | object | `{"coinbase":null,"l1ConsensusHostApiKeyHeaders":[],"l1ConsensusHostApiKeys":[],"l1ConsensusUrls":["http://l1-full-node-sepolia-beacon.l1.svc.cluster.local:5052"],"l1ExecutionUrls":["http://l1-full-node-sepolia-execution.l1.svc.cluster.local:8545"],"logLevel":"info","metrics":{"otelCollectorEndpoint":"","otelExcludeMetrics":"","useGcloudLogging":false},"nodeJsOptions":["--no-warnings","--max-old-space-size=4096"],"preStartScript":"","remoteUrl":{"archiver":null,"blobSink":null,"proverBroker":null,"proverCoordinationNodes":[]},"replicas":1,"resources":{},"sentinel":{"enabled":false},"startCmd":[],"startupProbe":{"failureThreshold":20,"periodSeconds":30},"storage":{"archiveStorageMapSize":null,"dataDirectory":"/data","dataStoreMapSize":null,"p2pStorageMapSize":null,"worldStateMapSize":null}}` | Aztec node configuration |
| node.coinbase | string | `nil` | Address that will receive block or proof rewards For prover roles, this is the PROVER_ID |
| node.l1ExecutionUrls | list | `["http://l1-full-node-sepolia-execution.l1.svc.cluster.local:8545"]` | L1 Ethereum configuration Ethereum execution layer RPC endpoint(s) - comma separated list |
| node.logLevel | string | `"info"` | Log level - info, verbose, debug, trace |
| node.metrics | object | `{"otelCollectorEndpoint":"","otelExcludeMetrics":"","useGcloudLogging":false}` | Metrics configuration |
| node.nodeJsOptions | list | `["--no-warnings","--max-old-space-size=4096"]` | Node.js options |
| node.preStartScript | string | `""` | Pre-start script (runs before node starts) |
| node.remoteUrl | object | `{"archiver":null,"blobSink":null,"proverBroker":null,"proverCoordinationNodes":[]}` | Remote service URLs |
| node.replicas | int | `1` | Number of replicas |
| node.resources | object | `{}` | Resource requests and limits |
| node.sentinel | object | `{"enabled":false}` | Sentinel configuration - gathers slashing information |
| node.startCmd | list | `[]` | Start command flags Auto-generated based on role, but can be overridden for custom configurations Leave empty to use role-based defaults |
| node.startupProbe | object | `{"failureThreshold":20,"periodSeconds":30}` | Startup probe configuration |
| node.storage | object | `{"archiveStorageMapSize":null,"dataDirectory":"/data","dataStoreMapSize":null,"p2pStorageMapSize":null,"worldStateMapSize":null}` | Storage configuration |
| persistence.accessModes | list | `["ReadWriteOnce"]` | AccessModes |
| persistence.annotations | object | `{}` | Annotations for volume claim template |
| persistence.enabled | bool | `false` | Uses an emptyDir when not enabled |
| persistence.existingClaim | string | `nil` | Use an existing PVC |
| persistence.selector | object | `{}` | Selector for volume claim template |
| persistence.size | string | `"100Gi"` | Requested size |
| persistence.storageClassName | string | `nil` | Use a specific storage class |
| podAnnotations | object | `{}` | Pod annotations (e.g., for Keel auto-updates) |
| podManagementPolicy | string | `"Parallel"` | Pod management policy |
| prover.agent.count | int | `1` | Number of prover agents to run per pod |
| prover.agent.persistence | object | `{"size":"10Gi"}` | Persistence configuration for prover-agent Agent needs 10GB SSD per agent for CRS and temporary files |
| prover.agent.pollIntervalMs | int | `1000` | Agent polling interval in milliseconds |
| prover.agent.replicas | int | `1` | Number of prover agent replicas |
| prover.agent.resources | object | `{}` | Resource requests/limits for prover-agent pods Recommended: 32 cores, 128GB RAM per agent |
| prover.broker.persistence | object | `{"size":"10Gi"}` | Persistence configuration for prover-broker Broker needs 10GB SSD for job queue |
| prover.broker.resources | object | `{}` | Resource requests/limits for prover-broker pod |
| prover.id | string | `""` | Prover ID - address for receiving proof rewards Used by prover-node (usually matches publisherPrivateKey address) |
| prover.node.persistence | object | `{"size":"1000Gi"}` | Persistence configuration for prover-node Prover-node needs 1TB NVMe SSD for archiver data |
| prover.node.publisherPrivateKey | string | `""` | Ethereum private key for publishing proofs to L1 REQUIRED when role is 'prover' |
| prover.node.resources | object | `{}` | Resource requests/limits for prover-node pod |
| rbac.clusterRules | list | See `values.yaml` | Required ClusterRole rules |
| rbac.create | bool | `true` | Specifies whether RBAC resources are to be created |
| rbac.rules | list | See `values.yaml` | Required ClusterRole rules |
| role | string | `"sequencer"` | Role determines the type of Aztec node deployment Valid roles: fullnode, sequencer, prover |
| rollupVersion | string | `"canonical"` | Which rollup contract we want to follow from the registry |
| sequencer.attesterPrivateKey | string | `""` | Ethereum private key for attester (signs blocks and attestations) REQUIRED when role is 'sequencer' (unless using attesterPrivateKeySecretName) Use this field OR attesterPrivateKeySecretName, not both |
| sequencer.attesterPrivateKeySecretName | string | `""` | Name of existing Kubernetes secret containing keystore.json Use this field OR attesterPrivateKey, not both When set, the chart will use the external secret instead of creating one The secret must contain a key named "keystore.json" with the full keystore structure Create with: kubectl create secret generic <name> --from-file=keystore.json=keystore.json |
| service.admin.enabled | bool | `true` |  |
| service.admin.port | int | `8081` |  |
| service.headless.enabled | bool | `true` |  |
| service.httpPort | int | `8080` |  |
| service.ingress.annotations | object | `{}` |  |
| service.ingress.enabled | bool | `false` |  |
| service.ingress.hosts | list | `[]` |  |
| service.p2p.announcePort | int | `40400` |  |
| service.p2p.enabled | bool | `true` |  |
| service.p2p.nodePort | int | `30400` |  |
| service.p2p.nodePortEnabled | bool | `false` |  |
| service.p2p.port | int | `40400` |  |
| serviceAccount.annotations | object | `{}` | Annotations for the service account |
| serviceAccount.create | bool | `true` | Create a service account |
| serviceAccount.name | string | `""` | Name of the service account - if not set, the fullname will be used |
| updateStrategy | object | `{"type":"RollingUpdate"}` | Update strategy for the statefulset |

# Aztec Node Helm Chart

A Kubernetes Helm chart for deploying Aztec network nodes in different roles: Full Node, Sequencer, or Prover.

## Overview

This chart deploys Aztec nodes using a role-based architecture. A single chart handles three distinct deployment types:

- **Full Node** - Participates in the network by syncing and validating blocks
- **Sequencer** - Produces blocks and participates in consensus
- **Prover** - Generates zero-knowledge proofs for the network

## Quick Start

### Prerequisites

- Kubernetes cluster (v1.19+)
- Helm 3.0+
- L1 Ethereum RPC access (execution + consensus layers)

### Install a Full Node

```bash
helm install aztec-fullnode ./charts/aztec-node \
  -f charts/aztec-node/values-examples/fullnode.yaml \
  -n aztec-testnet --create-namespace
```

### Install a Sequencer

```bash
helm install aztec-sequencer ./charts/aztec-node \
  -f charts/aztec-node/values-examples/sequencer.yaml \
  --set sequencer.attesterPrivateKey="0xYOUR_PRIVATE_KEY" \
  -n aztec-testnet --create-namespace
```

**Requirements:**
- Ethereum private key with minimum 0.1 ETH on L1 (Sepolia for testnet)

**For production deployments:** Instead of passing the private key inline, you can reference an external Kubernetes secret. See [Using External Kubernetes Secrets](#using-external-kubernetes-secrets-sequencer) for details.

### Install a Prover

```bash
helm install aztec-prover ./charts/aztec-node \
  -f charts/aztec-node/values-examples/prover.yaml \
  --set prover.node.publisherPrivateKey="0xYOUR_PRIVATE_KEY" \
  -n aztec-testnet --create-namespace
```

**Note:** The prover role creates 3 StatefulSets:
- `l2-prover-node-{networkName}-broker` - Manages the job queue
- `l2-prover-node-{networkName}-node` - Creates jobs and publishes proofs to L1
- `l2-prover-node-{networkName}-agent` - Executes proof generation (can scale replicas)

## Architecture

### Role-Based Deployment

The chart uses a `role` field to determine the deployment type:

```yaml
role: fullnode  # Options: fullnode | sequencer | prover
```

Each role automatically configures the appropriate:
- Container command and flags
- Resource requirements
- Storage configuration
- Service endpoints
- Required secrets

### Storage Requirements

All storage sizes match [Aztec's official specifications](https://docs.aztec.network/the_aztec_network):

| Role/Component | Storage | Type |
|----------------|---------|------|
| Full Node | 1TB | NVMe SSD |
| Sequencer | 1TB | NVMe SSD |
| Prover Node | 1TB | NVMe SSD |
| Prover Broker | 10GB | SSD |
| Prover Agent | 10GB | SSD |

## Configuration

### Networks

Connect to predefined Aztec networks:

```yaml
network: testnet  # Options: testnet | devnet
```

Or configure a custom network:

```yaml
network: null  # Disable predefined network
customNetwork:
  l1ChainId: "11155111"
  registryContractAddress: "0x..."
  slashFactoryAddress: "0x..."
  feeAssetHandlerContractAddress: "0x..."
```

### L1 Ethereum Configuration

All roles require L1 Ethereum RPC access:

```yaml
node:
  l1ExecutionUrls:
    - "http://l1-full-node-sepolia-execution.l1.svc.cluster.local:8545"
  l1ConsensusUrls:
    - "http://l1-full-node-sepolia-beacon.l1.svc.cluster.local:5052"
```

### Persistence

Persistence is enabled by default and uses the cluster's default storage class:

```yaml
persistence:
  enabled: true
  size: 1000Gi  # Automatically set per role
  # storageClassName: local-path  # Optional: specify storage class
  accessModes:
    - ReadWriteOnce
```

**Component-Specific Sizes (Prover Role):**

The prover role allows per-component storage configuration:

```yaml
prover:
  node:
    persistence:
      size: 1000Gi  # Prover node (archiver data)
  broker:
    persistence:
      size: 10Gi    # Broker (job queue)
  agent:
    persistence:
      size: 10Gi    # Agent (CRS files)
```

### Networking

**P2P Configuration:**

```yaml
service:
  p2p:
    enabled: true
    nodePortEnabled: false  # Set true for external P2P
    port: 40400
```

**Host Networking (Optional):**

```yaml
hostNetwork: true  # Use host network for better P2P performance
```

**Note:** When using `hostNetwork: true`, ensure pod affinity is set to distribute pods across different nodes if running multiple replicas.

### Resource Allocation

Example resource configuration:

```yaml
node:
  resources:
    requests:
      cpu: "4"
      memory: "16Gi"
    limits:
      cpu: "8"
      memory: "32Gi"
```

**Prover-Specific Resources:**

```yaml
prover:
  broker:
    resources:
      requests:
        cpu: "1"
        memory: "4Gi"
  node:
    resources:
      requests:
        cpu: "2"
        memory: "8Gi"
  agent:
    replicas: 2  # Scale prover agents
    resources:
      requests:
        cpu: "16"   # High CPU for proof generation
        memory: "64Gi"
```

## Examples

See detailed configuration examples in [`values-examples/`](./values-examples/):

- [`fullnode.yaml`](./values-examples/fullnode.yaml) - Full node configuration
- [`sequencer.yaml`](./values-examples/sequencer.yaml) - Sequencer configuration
- [`prover.yaml`](./values-examples/prover.yaml) - Prover configuration
- [`README.md`](./values-examples/README.md) - Detailed deployment guide

## Monitoring

Access node endpoints (replace `sepolia` with your `networkName` value):

```bash
# HTTP RPC endpoint
# For fullnode
kubectl port-forward -n aztec-testnet svc/l2-full-node-sepolia-node 8080:8080
# For sequencer
kubectl port-forward -n aztec-testnet svc/l2-sequencer-node-sepolia-node 8080:8080
# For prover (prover-node component)
kubectl port-forward -n aztec-testnet svc/l2-prover-node-sepolia-node 8080:8080

# Admin endpoint (example for sequencer)
kubectl port-forward -n aztec-testnet svc/l2-sequencer-node-sepolia-node 8081:8081
```

### Verify Node is Running Properly

**1. Check node sync status:**

```bash
curl -X POST http://localhost:8080 --data '{"method": "node_getL2Tips"}'
```

You should see JSON response with the latest block number. If the block number is increasing, your node is syncing correctly.

**2. Check P2P connectivity (TCP):**

```bash
# Get the external IP or node port
kubectl get svc -n aztec-testnet

# Test TCP connectivity (replace with your IP/port)
nc -vz <EXTERNAL_IP> 40400
```

Expected: "Connection succeeded"

**3. Check P2P connectivity (UDP):**

```bash
nc -vu <EXTERNAL_IP> 40400
```

Expected: "Connection succeeded"

**4. View logs:**

```bash
kubectl logs -n aztec-testnet -l app.kubernetes.io/name=aztec-node --tail=100 -f
```

Look for messages indicating:
- Block synchronization progress
- P2P peer connections
- No error messages

## Upgrading

### Upgrade a Release

```bash
helm upgrade aztec-node ./charts/aztec-node \
  -f your-values.yaml \
  -n aztec-testnet
```

### Auto-Updates

Enable automatic image updates by setting the image pull policy:

```yaml
image:
  repository: aztecprotocol/aztec
  tag: latest
  pullPolicy: Always  # Pull latest image on every pod restart
```

**Important Notes:**
- Using `pullPolicy: Always` with `tag: latest` ensures you get the newest version when pods restart
- This is recommended for testnet/devnet deployments to stay up-to-date
- For production, pin to specific versions (e.g., `tag: "2.0.2"`) and use `pullPolicy: IfNotPresent`
- Sequencers should use `pullPolicy: Always` to maintain network compatibility

**Trigger an update manually:**

```bash
# Force pod restart to pull latest image (replace 'sepolia' with your networkName)
# For fullnode
kubectl rollout restart statefulset/l2-full-node-sepolia-node -n aztec-testnet
# For sequencer
kubectl rollout restart statefulset/l2-sequencer-node-sepolia-node -n aztec-testnet

# For prover components
kubectl rollout restart statefulset/l2-prover-node-sepolia-broker -n aztec-testnet
kubectl rollout restart statefulset/l2-prover-node-sepolia-node -n aztec-testnet
kubectl rollout restart statefulset/l2-prover-node-sepolia-agent -n aztec-testnet
```

### Scale Prover Agents

```bash
helm upgrade aztec-prover ./charts/aztec-node \
  -f charts/aztec-node/values-examples/prover.yaml \
  --set prover.agent.replicas=4 \
  -n aztec-testnet
```

## Uninstalling

```bash
helm uninstall aztec-node -n aztec-testnet
```

**Note:** PersistentVolumeClaims are not automatically deleted. Remove manually if needed:

```bash
kubectl delete pvc -n aztec-testnet -l app.kubernetes.io/name=aztec-node
```

## Security

**⚠️ Important Security Notes:**

1. **Private Keys:** Never commit private keys to version control
2. **Sequencer:** Use `--set sequencer.attesterPrivateKey="0x..."` when deploying
3. **Prover:** Use `--set prover.node.publisherPrivateKey="0x..."` when deploying
4. **Secrets Management:** Consider using external secret managers (Vault, Sealed Secrets, etc.)

### Using External Kubernetes Secrets (Sequencer)

For production deployments, you can reference an existing Kubernetes secret instead of providing the private key inline. This is recommended for GKE and other production environments.

**Step 1: Create your Kubernetes secret with the keystore.json content**

```bash
# Create the keystore.json content
cat > keystore.json << EOF
{
  "schemaVersion": 1,
  "validators": [
    {
      "attester": ["0xYOUR_PRIVATE_KEY"],
      "feeRecipient": "0x0000000000000000000000000000000000000000000000000000000000000000"
    }
  ]
}
EOF

# Create the Kubernetes secret
kubectl create secret generic aztec-sequencer-keystore \
  --from-file=keystore.json=keystore.json \
  -n aztec-testnet

# Clean up local file
rm keystore.json
```

**Step 2: Deploy the chart referencing the external secret**

```bash
helm install aztec-sequencer ./charts/aztec-node \
  -f charts/aztec-node/values-examples/sequencer.yaml \
  --set sequencer.attesterPrivateKeySecretName="aztec-sequencer-keystore" \
  -n aztec-testnet --create-namespace
```

**Or using a values file:**

```yaml
role: sequencer
sequencer:
  attesterPrivateKeySecretName: "aztec-sequencer-keystore"
  feeRecipient: "0x0000000000000000000000000000000000000000000000000000000000000000"
```

**Important:** When using `attesterPrivateKeySecretName`, do NOT set `attesterPrivateKey`. Use one method or the other, not both.

## Troubleshooting

### Pod Not Starting

Check startup probe timeout (sequencers may need longer):

```yaml
node:
  startupProbe:
    periodSeconds: 60
    failureThreshold: 30  # 30 minutes max
```

### Storage Issues

Verify PVC creation:

```bash
kubectl get pvc -n aztec-testnet
```

Check storage class availability:

```bash
kubectl get storageclass
```

### P2P Connectivity

For external P2P access, enable NodePort:

```yaml
service:
  p2p:
    nodePortEnabled: true
```

Or use host networking:

```yaml
hostNetwork: true
```

### Prover Components Not Communicating

Verify all 3 StatefulSets are running:

```bash
kubectl get statefulsets -n aztec-testnet
```

Check service DNS resolution:

```bash
kubectl get svc -n aztec-testnet | grep prover
```

## Resources

- [Aztec Documentation](https://docs.aztec.network)
- [Aztec Network Guide](https://docs.aztec.network/the_aztec_network)
- [Running an Aztec Node](https://docs.aztec.network/the_aztec_network/guides/run_nodes)
- [Chart Values Reference](./values.yaml)

## License

Apache 2.0

## Contributing

Contributions welcome! Please submit issues and pull requests to the repository.
