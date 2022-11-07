
Charon
===========

Charon is an open-source Ethereum Distributed validator client written in golang.


```bash
$ helm repo add obol https://obolnetwork.github.io/helm-charts
$ helm install my-release obol/charon
```

## Configuration

The following table lists the configurable parameters of the Charon chart and their default values.

| Parameter                | Description             | Default        |
| ------------------------ | ----------------------- | -------------- |
| `replicaCount` |  | `1` |
| `image.repository` |  | `"ghcr.io/obolnetwork/charon:v0.11.1"` |
| `image.pullPolicy` |  | `"IfNotPresent"` |
| `image.tag` |  | `""` |
| `imagePullSecrets` |  | `[]` |
| `nameOverride` |  | `""` |
| `fullnameOverride` |  | `""` |
| `serviceAccount.create` |  | `true` |
| `serviceAccount.annotations` |  | `{}` |
| `serviceAccount.name` |  | `""` |
| `podAnnotations` |  | `{}` |
| `podSecurityContext` |  | `{}` |
| `securityContext` |  | `{}` |
| `service.type` |  | `"ClusterIP"` |
| `service.port` |  | `80` |
| `resources` |  | `{}` |
| `autoscaling.enabled` |  | `false` |
| `autoscaling.minReplicas` |  | `1` |
| `autoscaling.maxReplicas` |  | `100` |
| `autoscaling.targetCPUUtilizationPercentage` |  | `80` |
| `nodeSelector` |  | `{}` |
| `tolerations` |  | `[]` |
| `affinity` |  | `{}` |

Useful Helm Client Commands:

* Install a chart: `helm install my-release obol/<chart-name>`
* Upgrade your application: `helm upgrade`
* Uninstall a chart: `helm uninstall my-release`
