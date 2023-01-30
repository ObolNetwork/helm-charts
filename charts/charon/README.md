
Charon
===========

![Version: 0.2.0](https://img.shields.io/badge/Version-0.2.0-informational?style=flat-square) ![Type: application](https://img.shields.io/badge/Type-application-informational?style=flat-square) ![AppVersion: 0.13.0](https://img.shields.io/badge/AppVersion-0.13.0-informational?style=flat-square)

Charon is an open-source Ethereum Distributed validator middleware written in golang.

**Homepage:** <https://obol.tech/>

## Source Code

* <https://github.com/ObolNetwork/charon>

## Values

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| affinity | object | `{}` |  |
| config.LockFile | string | `"/charon/cluster-lock/cluster-lock.json"` |  |
| config.beaconNodeEndpoints | string | `""` |  |
| config.builderApi | string | `""` |  |
| config.featureSet | string | `"stable"` |  |
| config.featureSetDisable | string | `""` |  |
| config.featureSetEnable | string | `""` |  |
| config.jaegerAddress | string | `"jaeger:6831"` |  |
| config.jaegerService | string | `"charon"` |  |
| config.logFormat | string | `"console"` |  |
| config.logLevel | string | `"info"` |  |
| config.lokiAddresses | string | `""` |  |
| config.lokiService | string | `"charon"` |  |
| config.monitoringAddress | string | `"0.0.0.0:3620"` |  |
| config.noVerify | bool | `false` |  |
| config.p2pAllowlist | string | `""` |  |
| config.p2pDenylist | string | `""` |  |
| config.p2pDisableReuseport | string | `""` |  |
| config.p2pExternalHostname | string | `""` |  |
| config.p2pExternalIp | string | `""` |  |
| config.p2pRelays | string | `""` |  |
| config.p2pTcpAddress | string | `"0.0.0.0:3610"` |  |
| config.privateKeyFile | string | `"/charon/charon-enr-private-key/charon-enr-private-key"` |  |
| config.simnetBeaconMock | string | `""` |  |
| config.simnetValidatorKeysDir | string | `""` |  |
| config.simnetValidatorMock | string | `""` |  |
| config.syntheticBlockProposals | string | `""` |  |
| config.validatorApiAddress | string | `"0.0.0.0:3600"` |  |
| fullnameOverride | string | `""` |  |
| image.pullPolicy | string | `"IfNotPresent"` |  |
| image.repository | string | `"obolnetwork/charon"` |  |
| image.tag | string | `"v0.13.0"` |  |
| imagePullSecrets | list | `[]` |  |
| livenessProbe.enabled | bool | `true` |  |
| livenessProbe.httpGet.path | string | `"/livez"` |  |
| livenessProbe.initialDelaySeconds | int | `10` |  |
| livenessProbe.periodSeconds | int | `5` |  |
| nameOverride | string | `""` |  |
| nodeSelector | object | `{}` |  |
| podAnnotations | object | `{}` |  |
| podDisruptionBudget.enabled | bool | `false` |  |
| podDisruptionBudget.maxUnavailable | int | `1` |  |
| priorityClassName | string | `""` |  |
| rbac.clusterRules[0].apiGroups[0] | string | `""` |  |
| rbac.clusterRules[0].resources[0] | string | `"nodes"` |  |
| rbac.clusterRules[0].verbs[0] | string | `"get"` |  |
| rbac.clusterRules[0].verbs[1] | string | `"list"` |  |
| rbac.clusterRules[0].verbs[2] | string | `"watch"` |  |
| rbac.enabled | bool | `true` |  |
| rbac.name | string | `""` |  |
| rbac.rules[0].apiGroups[0] | string | `""` |  |
| rbac.rules[0].resources[0] | string | `"services"` |  |
| rbac.rules[0].verbs[0] | string | `"get"` |  |
| rbac.rules[0].verbs[1] | string | `"list"` |  |
| rbac.rules[0].verbs[2] | string | `"watch"` |  |
| readinessProbe.enabled | bool | `true` |  |
| readinessProbe.httpGet.path | string | `"/readyz"` |  |
| readinessProbe.initialDelaySeconds | int | `5` |  |
| readinessProbe.periodSeconds | int | `3` |  |
| resources | object | `{}` |  |
| secrets.clusterlock | string | `"cluster-lock"` |  |
| secrets.enrPrivateKey | string | `"charon-enr-private-key"` |  |
| secrets.validatorKeys | string | `"validator-keys"` |  |
| securityContext | string | `nil` |  |
| service.ports.monitoring.name | string | `"monitoring"` |  |
| service.ports.monitoring.port | int | `3620` |  |
| service.ports.monitoring.protocol | string | `"TCP"` |  |
| service.ports.monitoring.targetPort | int | `3620` |  |
| service.ports.p2pTcp.name | string | `"p2p-tcp"` |  |
| service.ports.p2pTcp.port | int | `3610` |  |
| service.ports.p2pTcp.protocol | string | `"TCP"` |  |
| service.ports.p2pTcp.targetPort | int | `3610` |  |
| service.ports.validatorApi.name | string | `"validator-api"` |  |
| service.ports.validatorApi.port | int | `3600` |  |
| service.ports.validatorApi.protocol | string | `"TCP"` |  |
| service.ports.validatorApi.targetPort | int | `3600` |  |
| service.type | string | `"ClusterIP"` |  |
| serviceAccount.annotations | object | `{}` |  |
| serviceAccount.enabled | bool | `true` |  |
| serviceAccount.name | string | `""` |  |
| serviceMonitor.annotations | object | `{}` |  |
| serviceMonitor.enabled | bool | `true` |  |
| serviceMonitor.interval | string | `"1m"` |  |
| serviceMonitor.labels | object | `{}` |  |
| serviceMonitor.namespace | string | `nil` |  |
| serviceMonitor.path | string | `"/metrics"` |  |
| serviceMonitor.relabelings | list | `[]` |  |
| serviceMonitor.scheme | string | `"http"` |  |
| serviceMonitor.scrapeTimeout | string | `"30s"` |  |
| serviceMonitor.tlsConfig | object | `{}` | ServiceMonitor TLS configuration |
| tolerations | object | `{}` |  |

# Usage Example

* Installs Charon distributed validator client node [Charon](https://github.com/ObolNetwork/charon)

## Add Obol's Helm Charts

```console
helm repo add obol https://obolnetwork.github.io/helm-charts
helm repo update
```

_See [helm repo](https://helm.sh/docs/helm/helm_repo/) for command documentation._

## Prerequisites
The charon cluster keys must be generated beforehand and populated to your Kubernetes cluster as secrets in the same namespace where the chart will get deployed.

These are the secrets that should exist the charon node:
`validator-keys`
`charon-enr-private-key`
`cluster-lock`

You can create the secrets from `.charon` directory as the following:
```console
files=""
for secret in ./.charon/validator_keys/*; do
    files="$files --from-file=./.charon/validator_keys/$(basename $secret)"
done
kubectl -n $NAME_SPACE create secret generic validator-keys $files --dry-run=client -o yaml | kubectl apply -f -
kubectl -n $NAME_SPACE create secret generic charon-enr-private-key --from-file=charon-enr-private-key=./.charon/charon-enr-private-key --dry-run=client -o yaml | kubectl apply -f -
kubectl -n $NAME_SPACE create secret generic cluster-lock --from-file=cluster-lock.json=./.charon/cluster-lock.json --dry-run=client -o yaml | kubectl apply -f -
```

## Installing the Chart

To install the chart with the release name `charon-node`:

```console
helm upgrade --install charon-node obol/charon \
  --set='config.beaconNodeEndpoints=<BEACON_NODES_ENDPOINTS>' \
  --create-namespace \
  --namespace <charon-node-namespace>
```

## Uninstalling the Chart

To uninstall and delete the `charon-node`:

```console
helm uninstall charon-node
```
The command removes all the Kubernetes components associated with the chart and deletes the release.
