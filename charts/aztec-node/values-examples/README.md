# Aztec Node Deployment Examples

This directory contains example values files for deploying Aztec nodes in different roles.

## L1 Infrastructure for Sequencers

Before deploying a sequencer, you need L1 infrastructure (Ethereum execution + consensus clients). The examples directory includes production-tested configurations for Sepolia testnet.

**Note**: L1 node requirements (Geth + Prysm) are separate from Aztec sequencer requirements. You can run them on the same machine or separate machines depending on your setup.

### Quick Start - Deploy L1 Stack

```bash
# 1. Add ethpandaops Helm repository
helm repo add ethpandaops https://ethpandaops.github.io/ethereum-helm-charts
helm repo update

# 2. Deploy Geth (execution client)
helm install geth-sepolia ethpandaops/geth \
  -f charts/aztec-node/values-examples/geth-sepolia.yaml \
  -n l1 --create-namespace

# 3. Deploy Prysm (consensus client)
helm install prysm-sepolia ethpandaops/prysm \
  -f charts/aztec-node/values-examples/prysm-sepolia.yaml \
  -n l1

# 4. Wait for sync (check logs)
kubectl logs -f geth-sepolia-0 -n l1
kubectl logs -f prysm-sepolia-0 -n l1

# 5. Deploy Aztec sequencer (once L1 is synced)
helm install aztec-sequencer ./charts/aztec-node \
  -f charts/aztec-node/values-examples/sequencer.yaml \
  --set sequencer.attesterPrivateKey="0xYOUR_PRIVATE_KEY" \
  -n aztec-testnet --create-namespace
```

### L1 Configuration Files

- **`geth-sepolia.yaml`** - Geth v1.16.7 execution client
  - Snap sync mode for fast initial sync
  - **Resources**: 2-4 cores, 8-16GB RAM
  - **Storage**: 500Gi NVMe SSD (Sepolia currently ~300-400GB)
  - Engine API on port 8551 (for Prysm)
  - JSON-RPC on port 8545 (for Aztec)

- **`prysm-sepolia.yaml`** - Prysm v6.1.4 consensus client
  - **Critical flags**: `--subscribe-all-data-subnets`, `--blob-storage-layout=by-epoch`
  - Checkpoint sync enabled (5-10 minute sync vs hours)
  - **Resources**: 2-4 cores, 16GB RAM
  - **Storage**: 800Gi NVMe SSD (part of ~637GB total Geth+Prysm stack)
  - gRPC gateway on port 3500 (for Aztec)
  - **Important**: 10-minute liveness probe delay for data column warm-up

### JWT Configuration

Both Geth and Prysm use the same JWT secret for Engine API authentication. The example files include a production JWT, but you should generate your own:

```bash
# Generate new JWT secret
openssl rand -hex 32
```

Then update both `geth-sepolia.yaml` and `prysm-sepolia.yaml` with the new JWT value.

## Available Roles

### 1. Full Node (`fullnode.yaml`)
A full node participates in the Aztec network by running archiver and node services.

**Command:** `--node --archiver --network testnet`

**Use case:** Network participation, development, testing

**Requirements:**
- L1 Ethereum RPC access (execution + consensus)
- 1TB NVMe SSD
- 2-4 CPU cores, 8-16GB RAM

**Deploy:**
```bash
helm install aztec-fullnode ./charts/aztec-node \
  -f charts/aztec-node/values-examples/fullnode.yaml \
  -n aztec-testnet --create-namespace
```

### 2. Sequencer (`sequencer.yaml`)
A sequencer produces blocks and attestations for the network.

**Command:** `--node --archiver --sequencer --network staging-public`

**Use case:** Block production, network consensus participation

**Requirements:**
- **L1 Infrastructure**: Deploy Geth + Prysm first (see [L1 Infrastructure](#l1-infrastructure-for-sequencers))
- Ethereum private key with minimum 0.1 ETH on L1
- **Aztec Sequencer Hardware** (separate from L1 nodes):
  - **CPU**: 2-4 cores minimum (released in 2015 or later)
  - **RAM**: 16GB minimum
  - **Storage**: 1TB NVMe SSD for archiver data
  - **Network**: 25 Mbps or higher
- Host networking enabled for P2P performance

**Critical Configuration:**
- `sequencer.feeRecipient` - **REQUIRED** (node will crash if not set)
- `sequencer.attesterPrivateKey` - **REQUIRED** (must have ETH on L1)
- `node.startCmd` - Must include `--node --archiver --sequencer --network`
- `node.startupProbe` - Set to 60s period, 60 failureThreshold (1hr max startup)

**Deploy:**
```bash
# IMPORTANT: Deploy L1 infrastructure first! See "L1 Infrastructure for Sequencers" section above

# Then deploy sequencer with your private key
helm install aztec-sequencer ./charts/aztec-node \
  -f charts/aztec-node/values-examples/sequencer.yaml \
  --set sequencer.attesterPrivateKey="0xYOUR_PRIVATE_KEY" \
  -n aztec-testnet --create-namespace
```

### 3. Prover (`prover.yaml`)
The prover role deploys a complete distributed proving system with 3 components:
- **Prover Broker**: Manages job queue (`--prover-broker --network testnet`)
- **Prover Node**: Creates jobs and publishes proofs to L1 (`--prover-node --archiver --network testnet`)
- **Prover Agent(s)**: Execute proof computation (`--prover-agent --network testnet`)

**Use case:** Distributed proof generation and L1 publication

**Requirements:**
- L1 Ethereum RPC access (for prover-node)
- Ethereum private key with ETH for L1 proof submissions
- **Prover Broker**: 1-2 CPU cores, 4-8GB RAM, 10GB SSD
- **Prover Node**: 2-4 CPU cores, 8-16GB RAM, 1TB NVMe SSD
- **Prover Agent(s)**: **16-32 CPU cores, 64-128GB RAM per agent**, 10GB SSD per agent (high-performance compute)

**Deploy:**
```bash
# IMPORTANT: Set your publisher private key first!
helm install aztec-prover ./charts/aztec-node \
  -f charts/aztec-node/values-examples/prover.yaml \
  --set prover.node.publisherPrivateKey="0xYOUR_PRIVATE_KEY" \
  -n aztec-testnet --create-namespace
```

**Scale prover agents:**
```bash
# Increase number of prover agent pods
helm upgrade aztec-prover ./charts/aztec-node \
  -f charts/aztec-node/values-examples/prover.yaml \
  --set prover.agent.replicas=4 \
  --set prover.node.publisherPrivateKey="0xYOUR_PRIVATE_KEY" \
  -n aztec-testnet
```

**Persistence Configuration:**

Each prover component has independent storage configuration matching Aztec's minimum requirements:

```yaml
prover:
  node:
    persistence:
      size: 1000Gi  # Prover-node needs 1TB NVMe SSD for archiver data
  broker:
    persistence:
      size: 10Gi    # Broker needs 10GB SSD for job queue
  agent:
    persistence:
      size: 10Gi    # Agent needs 10GB SSD per agent for CRS
```

The global `persistence.enabled` flag controls persistence for all components.

## Role-Based Architecture

The chart uses a `role` field to determine the deployment type:

```yaml
role: fullnode  # fullnode | sequencer | prover
```

### Role Behavior

| Role | StatefulSets Created | Services Started |
|------|---------------------|------------------|
| **fullnode** | 1 | Aztec node with archiver |
| **sequencer** | 1 | Aztec node with archiver + sequencer |
| **prover** | 3 | Prover broker, prover node, prover agent(s) |

The prover role automatically handles internal communication between components:
- Prover node connects to broker at `http://<release-name>-prover-broker:8080`
- Prover agents connect to broker at `http://<release-name>-prover-broker:8080`

## Required Fields by Role

### Sequencer
- `sequencer.attesterPrivateKey` (required) - Must start with `0x`
- `sequencer.feeRecipient` (optional) - Defaults to zero address

### Prover
- `prover.node.publisherPrivateKey` (required) - Must start with `0x`
- `prover.id` (optional) - Address for receiving proof rewards
- `prover.agent.replicas` (optional) - Number of prover agent pods (default: 1)
- `prover.agent.count` (optional) - Number of prover threads per pod (default: 1)

## Network Selection

Use the `network` field to connect to predefined networks:

```yaml
network: testnet  # or devnet
```

For custom networks, omit `network` and provide:

```yaml
customNetwork:
  l1ChainId: "11155111"
  registryContractAddress: "0x..."
  slashFactoryAddress: "0x..."
  feeAssetHandlerContractAddress: "0x..."
```

## Advanced Configuration

See the main [values.yaml](../values.yaml) for all available configuration options including:
- Component-specific resource limits
- Metrics and observability
- Storage configuration
- Network policies
- Service configuration
- And more...
