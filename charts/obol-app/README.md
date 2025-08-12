Obol App
===========

![Version: 0.1.0](https://img.shields.io/badge/Version-0.1.0-informational?style=flat-square) ![Type: application](https://img.shields.io/badge/Type-application-informational?style=flat-square) ![AppVersion: latest](https://img.shields.io/badge/AppVersion-latest-informational?style=flat-square)

A chart for running any Docker image within the Obol Stack.

## Usage Examples

### Basic Usage
```sh
# Add the Obol Chart Repo (if not using obolup)
helm repo add obol https://obolnetwork.github.io/helm-charts/

# Install with default nginx image
helm install my-app obol/obol-app

# Install with custom image
helm install my-app obol/obol-app --set image.repository=busybox
```

### Advanced Usage

#### Expose an image with a UI
```sh
# Enabling the ingress exposes the app on http://obol.stack/obol-app. The default docker port is 80, and can be changed with --set service.port
helm install my-app obol/obol-app \
  --set ingress.enabled=true
```

#### Custom Environment Variables
```sh
# Add custom environment variables to your container
helm install my-env-app obol/obol-app \
  --set image.repository=alpine \
  --set-json 'image.entrypoint=["/bin/sh"]' \
  --set-json 'image.args=["-c", "env && sleep 300"]' \
  --set-json 'image.environment=[{"name":"CUSTOM_VAR","value":"custom-value"},{"name":"OBOL_BEACON_API_URL","value":"http://l1-full-node-consensus.l1.svc.cluster.local:5052"}]'
```

#### Override the Default Docker Entrypoint
```sh
# Override the Docker image's ENTRYPOINT
helm install my-app obol/obol-app \
  --set image.repository=alpine \
  --set-json 'image.entrypoint=["/bin/sh"]' \
  --set-json 'image.args=["-c", "echo Hello from custom entrypoint && sleep 300"]'
```

#### Override the Docker Command (CMD)
```sh
# Override the Docker image's CMD
helm install my-cmd-app obol/obol-app \
  --set image.repository=busybox \
  --set-json 'image.command=["sleep", "3600"]'
```

#### Append Arguments to Default Entrypoint
```sh
# Add arguments to the default Docker entrypoint
helm install my-args-app obol/obol-app \
  --set image.repository=nginx \
  --set-json 'image.args=["-g", "daemon off;"]'
```

#### Complex Configuration with Custom Registry
```sh
# Full custom configuration
helm install my-foundry-app obol/obol-app \
  --set image.registry="gchr.io" \
  --set image.repository=foundry-rs/foundry \
  --set image.tag=latest \
  --set-json 'image.entrypoint=["/bin/sh"]' \
  --set-json 'image.args=["-c", "foundry"]' \
  --set-json 'image.environment=[{"name":"ETH_RPC_URL","value":"http://rpc.l1.svc.cluster.local/rpc/mainnet"}]'
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
| image.repository | string | `"nginx"` |  |
| image.tag | string | `""` |  |
| imagePullSecrets | list | `[]` |  |
| ingress.annotations | object | `{}` |  |
| ingress.className | string | `""` |  |
| ingress.enabled | bool | `false` |  |
| ingress.hosts[0].host | string | `"obol.stack"` |  |
| ingress.hosts[0].paths[0].path | string | `"/obol-app"` |  |
| ingress.hosts[0].paths[0].pathType | string | `"Prefix"` |  |
| ingress.tls | list | `[]` |  |
| livenessProbe.httpGet.path | string | `"/"` |  |
| livenessProbe.httpGet.port | string | `"http"` |  |
| nameOverride | string | `""` |  |
| nodeSelector | object | `{}` |  |
| obol.stack.enabled | bool | `true` |  |
| obol.stack.ethRpcUrl | string | `"http://rpc.l1.svc.cluster.local/rpc/mainnet"` |  |
| podAnnotations | object | `{}` |  |
| podLabels | object | `{}` |  |
| podSecurityContext | object | `{}` |  |
| readinessProbe.httpGet.path | string | `"/"` |  |
| readinessProbe.httpGet.port | string | `"http"` |  |
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