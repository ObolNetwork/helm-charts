OpenClaw
===========

![Version: 0.1.0](https://img.shields.io/badge/Version-0.1.0-informational?style=flat-square) ![Type: application](https://img.shields.io/badge/Type-application-informational?style=flat-square) ![AppVersion: 2026.2.3](https://img.shields.io/badge/AppVersion-2026.2.3-informational?style=flat-square)

OpenClaw gateway deployment (agent runtime) for Kubernetes.

**Homepage:** <https://docs.openclaw.ai>

## Source Code

* <https://docs.openclaw.ai>

## Values

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| affinity | object | `{}` |  |
| config | object | `{"content":"","existingConfigMap":"","key":"openclaw.json"}` | Configuration for the OpenClaw config file (openclaw.json) |
| config.content | string | `""` | Optional raw JSON5 configuration (overrides generated config when set) |
| config.existingConfigMap | string | `""` | Use an existing ConfigMap instead of creating one |
| config.key | string | `"openclaw.json"` | ConfigMap key / filename |
| containerSecurityContext | object | `{"allowPrivilegeEscalation":false,"capabilities":{"drop":["ALL"]},"runAsGroup":1000,"runAsNonRoot":true,"runAsUser":1000,"seccompProfile":{"type":"RuntimeDefault"}}` | Container security context |
| erpc | object | `{"url":"http://erpc.erpc.svc.cluster.local:4000/rpc"}` | eRPC integration (exposed as ERPC_URL env var) |
| extraEnv | list | `[]` | Additional environment variables |
| extraVolumeMounts | list | `[]` | Additional volume mounts |
| extraVolumes | list | `[]` | Additional volumes |
| fullnameOverride | string | `""` | Override the full resource name |
| httpRoute | object | `{"annotations":{},"enabled":false,"hostnames":[],"parentRefs":[{"name":"traefik-gateway","namespace":"traefik","sectionName":"web"}],"pathPrefix":"/"}` | Gateway API HTTPRoute (recommended for Obol Stack / Traefik Gateway API) |
| httpRoute.hostnames | list | `[]` | Hostnames for routing (required when enabled) |
| image | object | `{"args":["gateway"],"command":["openclaw"],"env":[],"pullPolicy":"IfNotPresent","repository":"ghcr.io/obolnetwork/openclaw","tag":"v2026.2.3"}` | OpenClaw image repository, pull policy, and tag version |
| image.args | list | `["gateway"]` | Override the container args (CMD) |
| image.command | list | `["openclaw"]` | Override the container command (ENTRYPOINT) |
| image.env | list | `[]` | Additional environment variables for the container |
| imagePullSecrets | list | `[]` | Credentials to fetch images from private registry |
| ingress | object | `{"annotations":{},"className":"","enabled":false,"hosts":[{"host":"chart-example.local","paths":[{"path":"/","pathType":"Prefix"}]}],"tls":[]}` | Kubernetes Ingress (optional; not used in Obol Stack which uses Gateway API) |
| livenessProbe | object | `{"enabled":true,"failureThreshold":3,"initialDelaySeconds":10,"periodSeconds":10,"timeoutSeconds":5}` | Liveness probe (tcpSocket by default to avoid auth-protected HTTP endpoints) |
| models | object | `{"ollama":{"api":"","apiKeyEnvVar":"OLLAMA_API_KEY","apiKeyValue":"ollama-local","baseUrl":"http://ollama.llm.svc.cluster.local:11434/v1","enabled":true,"models":[{"id":"glm-4.7-flash","name":"glm-4.7-flash"}]}}` | Model provider configuration |
| models.ollama.api | string | `""` | OpenClaw provider API type (optional; omit to let OpenClaw auto-detect) |
| models.ollama.apiKeyEnvVar | string | `"OLLAMA_API_KEY"` | Env var used for provider API key interpolation in openclaw.json |
| models.ollama.apiKeyValue | string | `"ollama-local"` | Value set for the apiKey env var (not a secret for Ollama) |
| models.ollama.baseUrl | string | `"http://ollama.llm.svc.cluster.local:11434/v1"` | OpenAI-compatible base URL for Ollama |
| nameOverride | string | `""` | Override the chart name |
| nodeSelector | object | `{}` |  |
| openclaw | object | `{"gateway":{"auth":{"mode":"token"},"bind":"lan","http":{"endpoints":{"chatCompletions":{"enabled":true}}},"mode":"local"},"stateDir":"/data/.openclaw","workspaceDir":"/data/.openclaw/workspace"}` | OpenClaw state/workspace settings (paths should be inside persistence.mountPath) |
| persistence | object | `{"accessModes":["ReadWriteOnce"],"enabled":true,"existingClaim":"","mountPath":"/data","size":"1Gi","storageClass":""}` | Persistence settings for OpenClaw state directory (contains runtime state + secrets) |
| podAnnotations | object | `{}` | Pod annotations |
| podLabels | object | `{}` | Pod labels |
| podSecurityContext | object | `{"fsGroup":1000}` | Pod security context |
| priorityClassName | string | `""` |  |
| readinessProbe | object | `{"enabled":true,"failureThreshold":3,"initialDelaySeconds":5,"periodSeconds":5,"timeoutSeconds":3}` | Readiness probe (tcpSocket by default to avoid auth-protected HTTP endpoints) |
| replicaCount | int | `1` | Number of replicas (OpenClaw should run as a single instance) |
| resources | object | `{"limits":{"memory":"2Gi"},"requests":{"cpu":"250m","memory":"512Mi"}}` | Resource requests and limits |
| secrets | object | `{"create":true,"existingSecret":"","extraEnvFromSecrets":[],"gatewayToken":{"key":"OPENCLAW_GATEWAY_TOKEN","value":""},"name":""}` | OpenClaw secrets (one Secret per instance) |
| secrets.create | bool | `true` | Create the secret when existingSecret is not set |
| secrets.existingSecret | string | `""` | Use an existing secret instead of creating one |
| secrets.extraEnvFromSecrets | list | `[]` | Extra Secret names to load via envFrom (for provider/channel keys, etc.) |
| secrets.gatewayToken.key | string | `"OPENCLAW_GATEWAY_TOKEN"` | Secret key name + env var name for gateway token |
| secrets.gatewayToken.value | string | `""` | Explicit token value (discouraged). If empty, a token is generated and persisted across upgrades. |
| secrets.name | string | `""` | Override the created Secret name (defaults to <release>-openclaw-secrets) |
| service | object | `{"port":18789,"type":"ClusterIP"}` | Service configuration |
| serviceAccount | object | `{"annotations":{},"automount":false,"create":true,"name":""}` | Create a ServiceAccount for OpenClaw |
| serviceAccount.automount | bool | `false` | Automatically mount a ServiceAccount's API credentials? |
| skills | object | `{"archiveKey":"skills.tgz","configMapName":"","enabled":false,"extractDir":"/data/.openclaw/skills-injected","initContainer":{"image":{"pullPolicy":"IfNotPresent","repository":"busybox","tag":"1.36.1"}}}` | Skills injection from a ConfigMap archive (created by an external tool; e.g. `obol openclaw skills sync`) |
| skills.configMapName | string | `""` | Name of the ConfigMap containing the skills archive |
| startupProbe | object | `{"enabled":true,"failureThreshold":30,"periodSeconds":5,"timeoutSeconds":3}` | Startup probe (tcpSocket; allows generous boot time before liveness kicks in) |
| tolerations | list | `[]` |  |

## Quick start

Add Obol's Helm Charts:

```sh
helm repo add obol https://obolnetwork.github.io/helm-charts/
helm repo update
```

Install OpenClaw (ClusterIP only):

```sh
helm upgrade --install openclaw obol/openclaw --create-namespace --namespace openclaw
```

Port-forward for local access:

```sh
export POD_NAME=$(kubectl get pods -n openclaw -l "app.kubernetes.io/name=openclaw,app.kubernetes.io/instance=openclaw" -o jsonpath="{.items[0].metadata.name}")
kubectl -n openclaw port-forward $POD_NAME 18789:18789
open http://127.0.0.1:18789
```

Fetch the gateway token:

```sh
kubectl get secret -n openclaw openclaw-openclaw-secrets -o jsonpath='{.data.OPENCLAW_GATEWAY_TOKEN}' | base64 --decode
```

## Obol Stack (Gateway API)

If you're running Obol Stack with Traefik + Gateway API, enable `httpRoute`:

```sh
helm upgrade --install openclaw obol/openclaw \
  --namespace openclaw \
  --set httpRoute.enabled=true \
  --set httpRoute.hostnames[0]=openclaw-myid.obol.stack
```

## Skills injection (ConfigMap archive)

This chart can extract a `skills.tgz` archive from a ConfigMap into the OpenClaw state volume.

Expected ConfigMap:
- Name: `skills.configMapName`
- Key: `skills.archiveKey` (default `skills.tgz`)

Enable extraction:

```sh
helm upgrade --install openclaw obol/openclaw \
  --namespace openclaw \
  --set skills.enabled=true \
  --set skills.configMapName=openclaw-skills
```
