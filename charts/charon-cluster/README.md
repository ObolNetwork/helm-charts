
Charon Cluster
===========

![Version: 0.1.1](https://img.shields.io/badge/Version-0.1.1-informational?style=flat-square) ![Type: application](https://img.shields.io/badge/Type-application-informational?style=flat-square) ![AppVersion: 0.13.0](https://img.shields.io/badge/AppVersion-0.13.0-informational?style=flat-square)

Charon is an open-source Ethereum Distributed validator middleware written in golang. This chart deploys a full Charon cluster.

**Homepage:** <https://obol.tech/>

## Source Code

* <https://github.com/ObolNetwork/charon>

## Values

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| affinity | object | `{}` |  |
| clusterSize | int | `4` |  |
| clusterThreshold | int | `3` |  |
| config.LockFile | string | `"/charon/cluster-lock.json"` |  |
| config.beaconNodeEndpoints | string | `""` |  |
| config.builderApi | string | `""` |  |
| config.directConnectionEnabled | string | `"true"` |  |
| config.featureSet | string | `"stable"` |  |
| config.featureSetDisable | string | `""` |  |
| config.featureSetEnable | string | `""` |  |
| config.jaegerAddress | string | `"jaeger:6831"` |  |
| config.jaegerService | string | `""` |  |
| config.logFormat | string | `"console"` |  |
| config.logLevel | string | `"info"` |  |
| config.lokiAddresses | string | `""` |  |
| config.lokiService | string | `""` |  |
| config.monitoringAddress | string | `"0.0.0.0:3620"` |  |
| config.noVerify | bool | `false` |  |
| config.p2pAllowlist | string | `""` |  |
| config.p2pDenylist | string | `""` |  |
| config.p2pDisableReuseport | string | `""` |  |
| config.p2pExternalHostname | string | `""` |  |
| config.p2pExternalIp | string | `""` |  |
| config.p2pRelays | string | `""` |  |
| config.p2pTcpAddress | string | `"0.0.0.0:3610"` |  |
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
| podDisruptionBudget.enabled | bool | `true` |  |
| podDisruptionBudget.minAvailable | string | `""` |  |
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
| secrets.validatorKeys | string | `"validators"` |  |
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
| updateStrategy | string | `"RollingUpdate"` |  |

# How to use the chart

Installs [Charon](https://github.com/ObolNetwork/charon) full cluster

## Add Obol's Helm Charts

```console
helm repo add obol https://obolnetwork.github.io/helm-charts
helm repo update
```
_See [helm repo](https://helm.sh/docs/helm/helm_repo/) for command documentation._

## Prerequisites
- You completed the DKG ceremony and have generated the `.charon` directory.
- The charon cluster keys are added to the Kubernetes cluster as secrets in the same namespace where the charon cluster is deployed.

### Example: How to create the k8s secrets from a `.charon` directory:
```console
cat << 'EOF' >> create-k8s-secrets.sh
i=0
CLUSTER_NAME=charon-cluster
CHARON_CLUSTER_NAMESPACE=charon-cluster
NODES=4
# set current namespace
kubectl config set-context --current --namespace=$CHARON_CLUSTER_NAMESPACE
kubectl -n $CHARON_CLUSTER_NAMESPACE create secret generic cluster-lock --from-file=cluster-lock.json=.charon/cluster/cluster-lock.json --dry-run=client -o yaml | kubectl apply -f -
while [[ $i -lt "$NODES" ]]
do
    files=""
    for secret in .charon/cluster/node${i}/validator_keys/*; do
        files="$files --from-file=.charon/cluster/node${i}/validator_keys/$(basename $secret)"
    done
    kubectl -n $CHARON_CLUSTER_NAMESPACE create secret generic ${CLUSTER_NAME}-${i}-validators $files --dry-run=client -o yaml | kubectl apply -f -
    kubectl -n $CHARON_CLUSTER_NAMESPACE create secret generic ${CLUSTER_NAME}-${i}-charon-enr-private-key --from-file=charon-enr-private-key=.charon/cluster/node${i}/charon-enr-private-key --dry-run=client -o yaml | kubectl apply -f -
    ((i=i+1))
done
EOF
chmod +x create-k8s-secrets.sh && ./create-k8s-secrets.sh
```

### Check the secrets are created
```console
kubeclt -n $CHARON_NODE_NAMESPACE get secrets
```
You should get list of charon secrets as the following:
- `<cluster-name>-<node-index>-validators`
- `<cluster-name>-<node-index>-charon-enr-private-key`
- `cluster-lock`

## Install the Chart
To install the chart with the release name `charon-cluster`:
```console
helm upgrade --install charon-cluster obol/charon-cluster \
  --set='clusterSize=4' \
  --set='config.beaconNodeEndpoints=<BEACON_NODES_ENDPOINTS>' \
  --create-namespace \
  --namespace $CHARON_NODE_NAMESPACE
```

## Connect your validator client
Ensure the charon node is up and healthy:
```console
kubectl -n $CHARON_NODE_NAMESPACE
```
Update the validator client to connect to charon node API endpoint.
For example:
- Teku: `--beacon-node-api-endpoint="http://CHARON_NODE_SERVICE_NAME:3600"`
You need to repeat that for each VC and charon node pair.

## Uninstall the Chart
To uninstall and delete the `charon-cluster`:
```console
helm uninstall charon-cluster
```
The command removes all the Kubernetes components associated with the chart and deletes the release.
