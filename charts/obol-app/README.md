Obol App
===========

![Version: 0.1.0](https://img.shields.io/badge/Version-0.1.0-informational?style=flat-square) ![Type: application](https://img.shields.io/badge/Type-application-informational?style=flat-square) ![AppVersion: latest](https://img.shields.io/badge/AppVersion-latest-informational?style=flat-square)

A chart for running any Docker image within the Obol Stack.

## Usage Examples

The `obol-app` chart is designed to run any containerized application within the Obol distributed validator stack. It provides automatic integration with Obol services and flexible configuration options.

### Quick Start

**If using obol-stack:** The Helm repository is automatically configured - skip to the install commands below.

**If not using obol-stack:** Add the Obol Helm repository first:
```sh
helm repo add obol https://obolnetwork.github.io/helm-charts/
helm repo update
```

**Install the chart:**
```sh
# Install with default busybox image (displays Obol ASCII art for 30 seconds)
helm install my-demo-app obol/obol-app

# Or install with a custom image
helm install my-app obol/obol-app --set image.repository=alpine
```

### Real-World Use Cases

#### 1. Ethereum Block Explorer
Deploy a lightweight Ethereum block explorer connected to your Obol stack:

```sh
helm install block-explorer obol/obol-app \
  --set image.repository=alethio/ethereum-lite-explorer \
  --set image.tag=latest \
  --set service.port=8080 \
  --set ingress.enabled=true \
  --set ingress.hosts[0].host=explorer.obol.stack \
  --set ingress.hosts[0].paths[0].path=/ \
  --set ingress.hosts[0].paths[0].pathType=Prefix \
  --set-json 'image.environment=[
    {"name":"APP_NODE_URL","value":"http://rpc.l1.svc.cluster.local/rpc/mainnet"}
  ]'
```

#### 2. Monitoring Dashboard
Run Grafana for monitoring your distributed validators:

```sh
helm install obol-grafana obol/obol-app \
  --set image.repository=grafana/grafana \
  --set image.tag=latest \
  --set service.port=3000 \
  --set ingress.enabled=true \
  --set ingress.hosts[0].host=monitoring.obol.stack \
  --set-json 'image.environment=[
    {"name":"GF_SECURITY_ADMIN_PASSWORD","value":"admin123"},
    {"name":"GF_INSTALL_PLUGINS","value":"grafana-piechart-panel"}
  ]'
```

#### 3. Web3 Development Environment
Set up a Hardhat development environment with Obol RPC access:

```sh
helm install hardhat-env obol/obol-app \
  --set image.repository=node \
  --set image.tag=18-alpine \
  --set-json 'image.entrypoint=["/bin/sh"]' \
  --set-json 'image.args=["-c", "npx hardhat console --network obol"]' \
  --set-json 'image.environment=[
    {"name":"HARDHAT_NETWORK","value":"obol"},
    {"name":"OBOL_RPC_URL","value":"http://rpc.l1.svc.cluster.local/rpc/mainnet"}
  ]'
```

#### 4. IPFS Gateway for DApp Assets
Deploy an IPFS gateway for storing and serving DApp assets:

```sh
helm install ipfs-gateway obol/obol-app \
  --set image.repository=ipfs/go-ipfs \
  --set image.tag=latest \
  --set service.port=8080 \
  --set ingress.enabled=true \
  --set ingress.hosts[0].host=ipfs.obol.stack \
  --set-json 'image.command=["/usr/local/bin/start_ipfs"]' \
  --set-json 'image.args=["daemon", "--migrate=true"]'
```

#### 5. Custom DApp Backend
Run a Node.js API server that connects to your Ethereum node:

```sh
helm install dapp-api obol/obol-app \
  --set image.repository=node \
  --set image.tag=18-alpine \
  --set service.port=3001 \
  --set-json 'image.entrypoint=["/bin/sh"]' \
  --set-json 'image.args=["-c", "npm start"]' \
  --set-json 'image.environment=[
    {"name":"PORT","value":"3001"},
    {"name":"NODE_ENV","value":"production"}
  ]'
```

### Advanced Configuration

#### Health Checks and Monitoring
Enable liveness and readiness probes for production deployments:

```sh
helm install production-app obol/obol-app \
  --set image.repository=nginx \
  --set-json 'livenessProbe={
    "httpGet": {
      "path": "/health",
      "port": "http"
    },
    "initialDelaySeconds": 30,
    "periodSeconds": 10
  }' \
  --set-json 'readinessProbe={
    "httpGet": {
      "path": "/ready",
      "port": "http"
    },
    "initialDelaySeconds": 5,
    "periodSeconds": 5
  }'
```

#### Resource Management
Configure resource limits and requests:

```sh
helm install resource-managed-app obol/obol-app \
  --set image.repository=nginx \
  --set-json 'resources={
    "limits": {
      "cpu": "500m",
      "memory": "512Mi"
    },
    "requests": {
      "cpu": "100m",
      "memory": "128Mi"
    }
  }'
```

#### Private Registry with Authentication
Deploy from a private Docker registry:

```sh
helm install private-app obol/obol-app \
  --set image.registry=myregistry.io \
  --set image.repository=mycompany/myapp \
  --set image.tag=v1.0.0 \
  --set image.auth.enabled=true \
  --set image.auth.secretName=my-registry-secret
```

### Testing and Validation

#### Quick Health Check
```sh
# Test basic connectivity after deployment
kubectl run test-pod --rm -i --tty --image=curlimages/curl -- \
  curl http://my-web-app-obol-app.default.svc.cluster.local
```

#### Environment Variable Verification
```sh
# Deploy a debug container to verify environment setup
helm install env-check obol/obol-app \
  --set image.repository=alpine \
  --set-json 'image.entrypoint=["/bin/sh"]' \
  --set-json 'image.args=["-c", "env | grep OBOL && sleep 300"]'

# Check the logs
kubectl logs -f env-check-obol-app
```

### Cleanup Examples
```sh
# Remove specific deployment
helm uninstall block-explorer

# Remove all test deployments
helm list | grep obol-app | awk '{print $1}' | xargs -n1 helm uninstall
```

**Homepage:** <https://obol.org/>

## Source Code

* <https://github.com/ObolNetwork/helm-charts>

## Values

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| affinity | object | `{}` |  |
| autoscaling.enabled | bool | `false` |  |
| autoscaling.maxReplicas | int | `100` |  |
| autoscaling.minReplicas | int | `1` |  |
| autoscaling.targetCPUUtilizationPercentage | int | `80` |  |
| fullnameOverride | string | `""` |  |
| image.args | list | `[]` |  |
| image.auth.enabled | bool | `false` |  |
| image.auth.secretName | string | `""` |  |
| image.command | list | `[]` |  |
| image.entrypoint | list | `[]` |  |
| image.environment | list | `[]` |  |
| image.pullPolicy | string | `"IfNotPresent"` |  |
| image.registry | string | `""` |  |
| image.repository | string | `"busybox"` |  |
| image.tag | string | `""` |  |
| imagePullSecrets | list | `[]` |  |
| ingress.annotations | object | `{}` |  |
| ingress.className | string | `"nginx"` |  |
| ingress.enabled | bool | `false` |  |
| ingress.hosts[0].host | string | `"obol.stack"` |  |
| ingress.hosts[0].paths[0].path | string | `"/obol-app"` |  |
| ingress.hosts[0].paths[0].pathType | string | `"Prefix"` |  |
| ingress.tls | list | `[]` |  |
| livenessProbe | object | `{}` |  |
| nameOverride | string | `""` |  |
| nodeSelector | object | `{}` |  |
| obol.stack.enabled | bool | `true` |  |
| obol.stack.ethRpcUrl | string | `"http://rpc.l1.svc.cluster.local/rpc/mainnet"` |  |
| podAnnotations | object | `{}` |  |
| podLabels | object | `{}` |  |
| podSecurityContext | object | `{}` |  |
| readinessProbe | object | `{}` |  |
| replicaCount | int | `1` |  |
| resources | object | `{}` |  |
| securityContext | object | `{}` |  |
| service.port | int | `80` |  |
| service.type | string | `"ClusterIP"` |  |
| serviceAccount.annotations | object | `{}` |  |
| serviceAccount.automount | bool | `true` |  |
| serviceAccount.create | bool | `true` |  |
| serviceAccount.name | string | `""` |  |
| tolerations | list | `[]` |  |
| volumeMounts | list | `[]` |  |
| volumes | list | `[]` |  |