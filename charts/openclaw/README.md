OpenClaw
===========

![Version: 0.1.0](https://img.shields.io/badge/Version-0.1.0-informational?style=flat-square) ![Type: application](https://img.shields.io/badge/Type-application-informational?style=flat-square) ![AppVersion: 2026.2.9](https://img.shields.io/badge/AppVersion-2026.2.9-informational?style=flat-square)

OpenClaw gateway deployment (agent runtime) for Kubernetes.

**Homepage:** <https://docs.openclaw.ai>

## Source Code

* <https://docs.openclaw.ai>

## Requirements

Kubernetes: `>=1.26.0-0`

## Quick start

Add Obol's Helm Charts:

```sh
helm repo add obol https://obolnetwork.github.io/helm-charts/
helm repo update
```

### Anthropic (recommended)

```sh
helm upgrade --install openclaw obol/openclaw \
  --namespace openclaw --create-namespace \
  --set-string secrets.gatewayToken.value=replace-with-long-random-token \
  --set models.anthropic.enabled=true \
  --set models.anthropic.apiKeyValue=sk-ant-api03-XXXX \
  --set models.ollama.enabled=false \
  --set openclaw.agentModel=anthropic/claude-opus-4-6
```

### OpenAI

```sh
helm upgrade --install openclaw obol/openclaw \
  --namespace openclaw --create-namespace \
  --set-string secrets.gatewayToken.value=replace-with-long-random-token \
  --set models.openai.enabled=true \
  --set models.openai.apiKeyValue=sk-XXXX \
  --set models.ollama.enabled=false \
  --set openclaw.agentModel=openai/gpt-5.2
```

### Ollama (local models)

The default values assume an [Obol Stack](https://github.com/ObolNetwork/obol-stack) environment
where Ollama traffic is routed through the llmspy proxy. For a standalone Ollama deployment, override
the base URL:

```sh
helm upgrade --install openclaw obol/openclaw \
  --namespace openclaw --create-namespace \
  --set-string secrets.gatewayToken.value=replace-with-long-random-token \
  --set models.ollama.baseUrl=http://ollama.ollama.svc.cluster.local:11434/v1 \
  --set models.ollama.api=""
```

## Access

Port-forward for local access:

```sh
kubectl -n openclaw port-forward svc/openclaw-openclaw 18789:18789
open http://127.0.0.1:18789
```

Fetch the gateway token:

```sh
kubectl get secret -n openclaw openclaw-openclaw-secrets \
  -o jsonpath='{.data.OPENCLAW_GATEWAY_TOKEN}' | base64 --decode
```

## Model providers

Three providers are supported. Enable any needed provider(s) with `models.<provider>.enabled`; all providers may be disabled.
API keys are stored in a Kubernetes Secret and injected as environment variables.

| Provider | `models.<name>.enabled` | API key value | Notes |
|----------|------------------------|---------------|-------|
| Anthropic | `models.anthropic.enabled=true` | `models.anthropic.apiKeyValue` | Direct API access |
| OpenAI | `models.openai.enabled=true` | `models.openai.apiKeyValue` | Direct API access |
| Ollama | `models.ollama.enabled=true` (default) | N/A | Default routes through llmspy in Obol Stack |

Set the default agent model with `openclaw.agentModel` (e.g. `anthropic/claude-opus-4-6`).

## Chat channels

OpenClaw can connect to messaging platforms. Enable channels and provide bot tokens:

### Telegram

```yaml
channels:
  telegram:
    enabled: true
    botToken: "123456:ABC-DEF..."
    dmPolicy: "open"  # open | paired | closed
```

### Discord

```yaml
channels:
  discord:
    enabled: true
    botToken: "MTIz..."
    dmPolicy: "open"
```

### Slack

```yaml
channels:
  slack:
    enabled: true
    botToken: "xoxb-..."
    appToken: "xapp-..."
```

## RBAC

Grant the OpenClaw service account read-only access to namespace resources:

If reusing an existing ServiceAccount (`serviceAccount.create=false`), you must also set `serviceAccount.name`.

```sh
helm upgrade --install openclaw obol/openclaw \
  --namespace openclaw \
  --set rbac.create=true \
  --set serviceAccount.automount=true \
  --set serviceAccount.create=false \
  --set serviceAccount.name=openclaw-sa
```

## Init Job

Run a one-shot Job after install to bootstrap the workspace:

The init Job requires persistent storage; keep `persistence.enabled=true`.

```sh
helm upgrade --install openclaw obol/openclaw \
  --namespace openclaw \
  --set initJob.enabled=true \
  --set persistence.enabled=true
```

## Skills injection

Extract a `skills.tgz` archive from a ConfigMap into the OpenClaw state volume.
When `skills.createDefault=true` (default), an empty ConfigMap is created automatically
so the chart deploys without external dependencies.

```sh
helm upgrade --install openclaw obol/openclaw \
  --namespace openclaw \
  --set skills.enabled=true
```

To use an externally managed ConfigMap instead:

```sh
helm upgrade --install openclaw obol/openclaw \
  --namespace openclaw \
  --set skills.enabled=true \
  --set skills.configMapName=my-skills-configmap
```

## Obol Stack (Gateway API)

If you're running Obol Stack with Traefik + Gateway API, enable `httpRoute`:

```sh
helm upgrade --install openclaw obol/openclaw \
  --namespace openclaw \
  --set httpRoute.enabled=true \
  --set "httpRoute.hostnames[0]=openclaw-myid.obol.stack"
```

## Values

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| affinity | object | `{}` |  |
| channels | object | `{"discord":{"botToken":"","dmPolicy":"","enabled":false},"slack":{"appToken":"","botToken":"","enabled":false},"telegram":{"botToken":"","dmPolicy":"","enabled":false}}` | Chat channel integrations Tokens are stored in the chart Secret and injected as env vars. |
| channels.discord.botToken | string | `""` | Discord bot token |
| channels.discord.dmPolicy | string | `""` | DM policy: "open" | "paired" | "closed" |
| channels.slack.appToken | string | `""` | Slack App-Level Token (xapp-...) |
| channels.slack.botToken | string | `""` | Slack Bot User OAuth Token (xoxb-...) |
| channels.telegram.botToken | string | `""` | Telegram Bot API token (from @BotFather) |
| channels.telegram.dmPolicy | string | `""` | DM policy: "open" | "paired" | "closed" |
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
| image | object | `{"args":["openclaw.mjs","gateway","--allow-unconfigured"],"command":["node"],"env":[],"pullPolicy":"IfNotPresent","repository":"ghcr.io/obolnetwork/openclaw","tag":"2026.2.9"}` | OpenClaw image repository, pull policy, and tag version |
| image.args | list | `["openclaw.mjs","gateway","--allow-unconfigured"]` | Override the container args (CMD) |
| image.command | list | `["node"]` | Override the container command (ENTRYPOINT) |
| image.env | list | `[]` | Additional environment variables for the container |
| imagePullSecrets | list | `[]` | Credentials to fetch images from private registry |
| ingress | object | `{"annotations":{},"className":"","enabled":false,"hosts":[{"host":"chart-example.local","paths":[{"path":"/","pathType":"Prefix"}]}],"tls":[]}` | Kubernetes Ingress (optional; not used in Obol Stack which uses Gateway API) |
| initJob | object | `{"args":[],"command":["node","openclaw.mjs","agent","init"],"enabled":false,"env":[],"image":{"pullPolicy":"IfNotPresent","repository":"ghcr.io/obolnetwork/openclaw","tag":""},"resources":{"limits":{"memory":"512Mi"},"requests":{"cpu":"100m","memory":"128Mi"}}}` | One-shot init Job (runs once to bootstrap workspace/personality) |
| initJob.enabled | bool | `false` | Enable a one-shot post-install bootstrap Job. Requires persistence.enabled=true. |
| initJob.env | list | `[]` | Extra environment variables for the init job |
| initJob.resources | object | `{"limits":{"memory":"512Mi"},"requests":{"cpu":"100m","memory":"128Mi"}}` | Resource requests/limits for the init job |
| livenessProbe | object | `{"enabled":true,"failureThreshold":3,"initialDelaySeconds":10,"periodSeconds":10,"timeoutSeconds":5}` | Liveness probe (tcpSocket by default to avoid auth-protected HTTP endpoints) |
| models | object | `{"anthropic":{"api":"","apiKeyEnvVar":"ANTHROPIC_API_KEY","apiKeyValue":"","baseUrl":"https://api.anthropic.com/v1","enabled":false,"models":[{"id":"claude-sonnet-4-5-20250929","name":"Claude Sonnet 4.5"},{"id":"claude-opus-4-6","name":"Claude Opus 4.6"}]},"ollama":{"api":"openai-completions","apiKeyEnvVar":"OLLAMA_API_KEY","apiKeyValue":"ollama-local","baseUrl":"http://llmspy.llm.svc.cluster.local:8000/v1","enabled":true,"models":[{"id":"glm-4.7-flash","name":"glm-4.7-flash"}]},"openai":{"api":"","apiKeyEnvVar":"OPENAI_API_KEY","apiKeyValue":"","baseUrl":"https://api.openai.com/v1","enabled":false,"models":[{"id":"gpt-5.2","name":"GPT-5.2"}]}}` | Model provider configuration Each provider is independently toggled. All providers may be disabled. API keys are stored in the chart Secret and injected as env vars. |
| models.anthropic.apiKeyValue | string | `""` | API key value (stored in Secret). Leave empty to provide via extraEnvFromSecrets. |
| models.ollama.api | string | `"openai-completions"` | OpenClaw provider API type. Set to "openai-completions" because llmspy exposes an OpenAI-compatible chat/completions endpoint. |
| models.ollama.apiKeyEnvVar | string | `"OLLAMA_API_KEY"` | Env var used for provider API key interpolation in openclaw.json |
| models.ollama.apiKeyValue | string | `"ollama-local"` | Value set for the apiKey env var (not a secret for Ollama) |
| models.ollama.baseUrl | string | `"http://llmspy.llm.svc.cluster.local:8000/v1"` | OpenAI-compatible base URL for Ollama (routed through llmspy global proxy) |
| nameOverride | string | `""` | Override the chart name |
| nodeSelector | object | `{}` |  |
| openclaw | object | `{"agentModel":"","gateway":{"auth":{"mode":"token"},"bind":"lan","http":{"endpoints":{"chatCompletions":{"enabled":true}}},"mode":"local"},"stateDir":"/data/.openclaw","workspaceDir":"/data/.openclaw/workspace"}` | OpenClaw state/workspace settings (paths should be inside persistence.mountPath) |
| openclaw.agentModel | string | `""` | Default agent model (e.g. "anthropic/claude-sonnet-4-5-20250929"). Empty = use provider default. |
| persistence | object | `{"accessModes":["ReadWriteOnce"],"enabled":true,"existingClaim":"","mountPath":"/data","size":"1Gi","storageClass":""}` | Persistence settings for OpenClaw state directory (contains runtime state + secrets) |
| podAnnotations | object | `{}` | Pod annotations |
| podLabels | object | `{}` | Pod labels |
| podSecurityContext | object | `{"fsGroup":1000}` | Pod security context |
| priorityClassName | string | `""` |  |
| rbac | object | `{"create":false,"extraRules":[]}` | RBAC for the ServiceAccount (read-only access to namespace resources) |
| rbac.extraRules | list | `[]` | Extra rules to append to the generated Role (list of PolicyRule objects) |
| readinessProbe | object | `{"enabled":true,"failureThreshold":3,"initialDelaySeconds":5,"periodSeconds":5,"timeoutSeconds":3}` | Readiness probe (tcpSocket by default to avoid auth-protected HTTP endpoints) |
| replicaCount | int | `1` | Number of replicas (OpenClaw should run as a single instance) |
| resources | object | `{"limits":{"memory":"2Gi"},"requests":{"cpu":"250m","memory":"512Mi"}}` | Resource requests and limits |
| secrets | object | `{"create":true,"existingSecret":"","extraEnvFromSecrets":[],"gatewayToken":{"key":"OPENCLAW_GATEWAY_TOKEN","value":""},"name":""}` | OpenClaw secrets (one Secret per instance) |
| secrets.create | bool | `true` | Create the secret when existingSecret is not set |
| secrets.existingSecret | string | `""` | Use an existing secret instead of creating one |
| secrets.extraEnvFromSecrets | list | `[]` | Extra Secret names to load via envFrom (for provider/channel keys, etc.) |
| secrets.gatewayToken.key | string | `"OPENCLAW_GATEWAY_TOKEN"` | Secret key name + env var name for the gateway API authentication token. This token is required to access OpenClaw's HTTP gateway (chat/completions endpoint and dashboard). |
| secrets.gatewayToken.value | string | `""` | Explicit token value. Required for token auth unless using secrets.existingSecret. |
| secrets.name | string | `""` | Override the created Secret name (defaults to <release>-openclaw-secrets) |
| service | object | `{"port":18789,"type":"ClusterIP"}` | Service configuration |
| serviceAccount | object | `{"annotations":{},"automount":false,"create":true,"name":""}` | Create a ServiceAccount for OpenClaw |
| serviceAccount.automount | bool | `false` | Automatically mount a ServiceAccount's API credentials? Set to true when rbac.create is true so the agent can access the K8s API. |
| serviceAccount.name | string | `""` | ServiceAccount name. Required when serviceAccount.create=false and rbac.create=true. |
| skills | object | `{"archiveKey":"skills.tgz","configMapName":"","createDefault":true,"enabled":false,"extractDir":"/data/.openclaw/skills-injected","initContainer":{"image":{"pullPolicy":"IfNotPresent","repository":"busybox","tag":"1.36.1"}}}` | Skills injection from a ConfigMap archive (created by an external tool; e.g. `obol openclaw skills sync`). The archive is extracted to `extractDir` by a busybox init container and wired into OpenClaw via `skills.load.extraDirs` in _helpers.tpl. Note: ConfigMap total size is limited to ~1 MB by Kubernetes. |
| skills.configMapName | string | `""` | Name of the ConfigMap containing the skills archive (overrides createDefault) |
| skills.createDefault | bool | `true` | Create a default empty skills ConfigMap when configMapName is not set. This allows the chart to deploy without requiring an external ConfigMap. Use `obol openclaw skills sync` to populate it later. |
| startupProbe | object | `{"enabled":true,"failureThreshold":30,"periodSeconds":5,"timeoutSeconds":3}` | Startup probe (tcpSocket; allows generous boot time before liveness kicks in) |
| tolerations | list | `[]` |  |
