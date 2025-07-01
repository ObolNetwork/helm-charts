# DV Pod Helm Chart

![Version: 0.2.0](https://img.shields.io/badge/Version-0.2.0-informational?style=flat-square) ![Type: application](https://img.shields.io/badge/Type-application-informational?style=flat-square) ![AppVersion: 1.4.3](https://img.shields.io/badge/AppVersion-1.4.3-informational?style=flat-square)

A Helm chart for deploying a single distributed validator pod with Charon middleware and validator client.

**Homepage:** <https://obol.tech/>

## Overview

This chart deploys a single distributed validator (DV) pod that runs:
- **Charon**: Distributed validator middleware that enables multiple operators to run a validator together
- **Validator Client**: Your choice of Ethereum validator client (Lighthouse, Teku, Prysm, Nimbus, or Lodestar)

The chart can optionally deploy:
- **Erigon**: Ethereum execution layer client (enabled by default for Hoodi testnet)
- **Teku**: Ethereum consensus layer client (disabled by default)

Or you can disable these and use external Ethereum execution and consensus layer endpoints.

## Prerequisites

- Kubernetes 1.19+
- Helm 3.0+
- An operator address registered with the Obol Network
- Either:
  - Sufficient resources to run embedded Erigon/Teku (if enabled)
  - OR external Ethereum execution and consensus layer endpoints

## Installation

```bash
# Add the Obol Helm repository
helm repo add obol https://obolnetwork.github.io/helm-charts
helm repo update

# Install the chart
helm install my-dv-pod obol/dv-pod \
  --set charon.operatorAddress=0xYourOperatorAddress
```

## Configuration

### Required Values

| Parameter | Description | Default |
|-----------|-------------|---------|
| `charon.operatorAddress` | Your Ethereum operator address | `""` (must be set) |
| `externalServices.consensusEndpoint` | External beacon node endpoint | `"http://beacon-node:5052"` |

### Key Configuration Options

#### Embedded Clients
```yaml
# Erigon (execution layer) - enabled by default
erigon:
  enabled: true
  extraArgs:
    - --chain=hoodi  # Default testnet

# Teku (consensus layer) - disabled by default
teku:
  enabled: false
```

#### External Services (when embedded clients are disabled)
```yaml
externalServices:
  executionEndpoint: ""  # Optional: execution layer endpoint
  consensusEndpoint: "http://beacon-node:5052"  # Required: beacon node endpoint
```

#### Validator Client
```yaml
validatorClient:
  enabled: true
  type: "lighthouse"  # Options: lighthouse, teku, prysm, nimbus, lodestar
  config:
    network: "mainnet"
    graffiti: "DV-Pod"
```

#### Charon Configuration
```yaml
charon:
  operatorAddress: ""  # Required: Your operator address
  dkgSidecar:
    enabled: true
    apiEndpoint: "https://api.obol.tech"
```

### ENR Management

The chart handles Ethereum Node Record (ENR) generation automatically. You can:
1. Let the chart generate an ENR automatically (default)
2. Provide your own ENR private key
3. Use an existing Kubernetes secret containing an ENR private key

See [ENR.md](./ENR.md) for detailed ENR management documentation.

### Skipping DKG Process

If you already have a cluster-lock.json from a previous DKG ceremony, you can skip the DKG process entirely:

```bash
# Create a secret with your existing cluster-lock.json
kubectl create secret generic cluster-lock --from-file=cluster-lock.json

# Install the chart - the DKG sidecar will detect the existing lock and exit immediately
helm install my-dv-pod obol/dv-pod \
  --set charon.operatorAddress=0xYourOperatorAddress
```

The DKG sidecar automatically handles three scenarios:
1. **Existing cluster-lock.json**: Exits immediately, allowing Charon to start with existing configuration
2. **Existing cluster-definition.json only**: Runs `charon dkg` to generate the cluster-lock.json
3. **Neither exists**: Polls the Obol API for cluster invites and runs full DKG when ready

## Architecture

```
┌─────────────────────────────────────┐
│         DV Pod (StatefulSet)        │
│                                     │
│ ┌─────────────────────────────────┐ │
│ │      DKG Sidecar (Init)         │ │
│ │   - Polls for cluster invite    │ │
│ │   - Manages DKG process         │ │
│ └─────────────────────────────────┘ │
│                                     │
│ ┌─────────────────────────────────┐ │
│ │         Charon Container        │ │
│ │   - Distributed validator       │ │
│ │   - P2P networking              │ │
│ │   - Validator API proxy         │ │
│ └─────────────────────────────────┘ │
│                                     │
│ ┌─────────────────────────────────┐ │
│ │    Validator Client Container   │ │
│ │   - Connects to Charon API      │ │
│ │   - Signs attestations/blocks   │ │
│ │   - Manages validator duties    │ │
│ └─────────────────────────────────┘ │
└─────────────────────────────────────┘
           │                    │
           ▼                    ▼
    External Services    P2P Network
    - Beacon Node       - Other DV nodes
    - Execution Client
```

## Validator Client Support

The chart supports multiple validator clients:

| Client | Image | Configuration |
|--------|-------|---------------|
| Lighthouse | `sigp/lighthouse` | Default, well-tested |
| Teku | `consensys/teku` | Enterprise-grade |
| Prysm | `gcr.io/prysmaticlabs/prysm/validator` | High performance |
| Nimbus | `statusim/nimbus-eth2` | Resource efficient |
| Lodestar | `chainsafe/lodestar` | TypeScript-based |

## Monitoring

The chart exposes metrics endpoints:
- Charon metrics: Port 3620
- Validator client metrics: Port 5064

Configure Prometheus ServiceMonitor:
```yaml
serviceMonitor:
  enabled: true
  interval: 30s
```

## Persistence

DKG artifacts and validator data are persisted using a PVC:
```yaml
persistence:
  enabled: true
  size: 1Gi
  storageClassName: ""  # Uses default storage class
```

## Security Considerations

1. **RBAC**: The chart creates appropriate roles and bindings
2. **Network Policies**: Consider implementing network policies for production
3. **Secret Management**: ENR private keys are stored in Kubernetes secrets
4. **Pod Security**: Configure security contexts as needed

## Troubleshooting

### Common Issues

1. **DKG Sidecar Failing**
   - Check operator address is correct
   - Verify cluster invite exists in Obol API
   - Check network connectivity to api.obol.tech

2. **Validator Client Not Starting**
   - Ensure Charon has completed DKG process
   - Check beacon node connectivity
   - Verify correct validator client type

3. **ENR Issues**
   - Check ENR secret exists: `kubectl get secret <release>-dv-pod-enr-key`
   - Verify ENR was generated: Check pod logs

## Upgrading

```bash
helm upgrade my-dv-pod obol/dv-pod \
  --set charon.operatorAddress=0xYourOperatorAddress \
  --set externalServices.consensusEndpoint=http://your-beacon-node:5052
```

## Uninstalling

```bash
helm uninstall my-dv-pod
```

**Warning**: This will delete the PVC containing DKG artifacts. Back up important data first.

## Contributing

See the [Obol Network GitHub repository](https://github.com/ObolNetwork/helm-charts) for contribution guidelines.

## License

This chart is licensed under the Apache 2.0 License.
