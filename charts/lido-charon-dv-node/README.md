# Lido Charon Distributed Validator Node Helm Chart

This Helm chart deploys a complete Lido Charon distributed validator node with all necessary components including execution client, consensus client, validator client, MEV-boost, and comprehensive monitoring stack.

## Prerequisites

- Kubernetes 1.19+
- Helm 3.2.0+
- PV provisioner support in the underlying infrastructure (for persistence)
- At least 16GB RAM and 4 CPU cores available in your cluster
- 1TB+ storage for mainnet (500GB for testnets)

## Components

This chart deploys the following components:

### Core Components
- **Nethermind**: Ethereum execution client
- **Lighthouse**: Ethereum consensus/beacon client  
- **Charon**: Distributed validator middleware by Obol
- **Lodestar**: Validator client
- **MEV-Boost**: MEV relay multiplexer

### Lido-specific Components
- **Validator Ejector**: Monitors and processes validator exit requests
- **Lido DV Exit**: Handles distributed validator exit coordination

### Monitoring Stack
- **Prometheus**: Metrics collection and storage
- **Grafana**: Metrics visualization with pre-configured dashboards
- **Loki**: Log aggregation system

## Installation

### Quick Start

1. Add the Helm repository (when published):
```bash
helm repo add obol https://charts.obol.tech
helm repo update
```

2. Create a values file with your configuration:
```yaml
# my-values.yaml
global:
  network: mainnet

validatorEjector:
  locatorAddress: "0x..." # Your Lido Locator address
  operatorId: "123"       # Your operator ID
  oracleAddressesAllowlist: "0x...,0x..." # Oracle addresses

prometheus:
  remoteWrite:
    enabled: true
    token: "your-monitoring-token"
```

3. Install the chart:
```bash
helm install my-dv-node obol/lido-charon-dv-node -f my-values.yaml
```

### Installation from Source

```bash
git clone https://github.com/ObolNetwork/helm-charts
cd helm-charts
helm install my-dv-node ./charts/lido-charon-dv-node -f my-values.yaml
```

## Configuration

See [values.yaml](values.yaml) for full configuration options.

### Essential Configuration

| Parameter | Description | Default | Required |
|-----------|-------------|---------|----------|
| `global.network` | Ethereum network (mainnet, hoodi) | `mainnet` | Yes |
| `validatorEjector.locatorAddress` | Lido Locator contract address | `""` | Yes |
| `validatorEjector.operatorId` | Your Lido operator ID | `""` | Yes |
| `validatorEjector.oracleAddressesAllowlist` | Comma-separated oracle addresses | `""` | Yes |
| `prometheus.remoteWrite.token` | Token for Obol monitoring | `""` | Recommended |

### Network Configuration

The chart automatically configures network-specific settings based on `global.network`:
- Checkpoint sync URLs
- MEV relay endpoints
- Lido execution rewards addresses
- Network chain configurations

### Storage Requirements

Default storage allocations (adjustable via values):
- Nethermind: 500Gi
- Lighthouse: 200Gi  
- Charon: 10Gi
- Prometheus: 50Gi
- Loki: 20Gi

### Resource Requirements

Default resource requests/limits:
- Nethermind: 2000m/4000m CPU, 4Gi/8Gi Memory
- Lighthouse: 1000m/2000m CPU, 2Gi/4Gi Memory
- Charon: 1000m/2000m CPU, 2Gi/4Gi Memory
- Other components: See values.yaml

## Persistence

All stateful components use PersistentVolumeClaims by default. To disable persistence (NOT recommended for production):

```yaml
nethermind:
  persistence:
    enabled: false
lighthouse:
  persistence:
    enabled: false
# etc...
```

## Monitoring

### Accessing Grafana

```bash
kubectl port-forward svc/my-dv-node-lido-charon-dv-node-grafana 3000:3000
```

Default credentials:
- Username: admin
- Password: admin (change via `grafana.adminPassword`)

### Prometheus Remote Write

Configure remote write to Obol monitoring:

```yaml
prometheus:
  remoteWrite:
    enabled: true
    url: https://vm.monitoring.gcp.obol.tech/write
    token: "your-token-here"
```

## Security

### Network Policies

Enable network policies to restrict pod-to-pod communication:

```yaml
networkPolicy:
  enabled: true
```

### Pod Security

The chart follows security best practices:
- Non-root containers
- Read-only root filesystems where possible
- Dropped capabilities
- Security contexts properly configured

## Upgrading

### From Docker Compose

1. Export your existing data
2. Create PVs with the exported data
3. Install the Helm chart pointing to existing PVs
4. Verify all services are running correctly

### Chart Upgrades

```bash
helm upgrade my-dv-node obol/lido-charon-dv-node -f my-values.yaml
```

## Troubleshooting

### Check Pod Status
```bash
kubectl get pods -l app.kubernetes.io/instance=my-dv-node
```

### View Logs
```bash
# Charon logs
kubectl logs -f statefulset/my-dv-node-lido-charon-dv-node-charon

# Lighthouse logs  
kubectl logs -f statefulset/my-dv-node-lido-charon-dv-node-lighthouse

# Validator ejector logs
kubectl logs -f deployment/my-dv-node-lido-charon-dv-node-validator-ejector
```

### Common Issues

1. **JWT Authentication Failures**: Ensure the JWT secret is properly shared between execution and consensus clients
2. **Sync Issues**: Check checkpoint sync URL is accessible and correct for your network
3. **Validator Ejector Errors**: Verify Lido configuration (locator address, operator ID, oracle allowlist)

## Supported Networks

This chart currently supports the following networks:
- **mainnet**: Ethereum mainnet
- **hoodi**: Hoodi testnet (recommended for testing)

Note: Goerli and Holesky testnets have been deprecated and are no longer supported.

## Contributing

Please read the contributing guide in the main repository.

## License

This chart is licensed under the Apache 2.0 license.