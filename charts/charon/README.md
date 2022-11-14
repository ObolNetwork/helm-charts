
Charon
===========

Charon is an open-source Ethereum Distributed validator client written in golang.

# Charon Helm Chart

* Installs Charon distributed validator client node [Charin](https://github.com/ObolNetwork/charon)

## Get Repo Info

```console
helm repo add obol https://obolnetwork.github.io/helm-charts
helm repo update
```

_See [helm repo](https://helm.sh/docs/helm/helm_repo/) for command documentation._

## Prerequisites
The charon cluster keys must be generated bebforehand and populated as secrets to the Kubernetes cluster to the same namespace where the chart will get deployed.

These are the secrets that should exist for a node name `node0`:
`node0-charon-enr-private-key`
`node0-cluster-lock`
`node0-validators`

## Installing the Chart

To install the chart with the release name `node0`:

```console
helm install node0 obol/charon --set charon.config.beaconNodeEndpoints=<BEACON_NODES_ENDPOINTS>
```

## Uninstalling the Chart

To uninstall/delete the my-release deployment:

```console
helm delete my-release
```

The command removes all the Kubernetes components associated with the chart and deletes the release.


## Configuration

The following table lists the configurable parameters of the Charon chart and their default values.

| Parameter                | Description             | Default        |
| ------------------------ | ----------------------- | -------------- |
| `global.imagePullSecrets` |  | `[]` |
| `global.serviceAccount.create` |  | `true` |
| `global.serviceAccount.annotations` |  | `{}` |
| `global.serviceAccount.name` |  | `""` |
| `global.livenessProbe.enabled` |  | `true` |
| `global.readinessProbe.enabled` |  | `true` |
| `image.repository` |  | `"ghcr.io/obolnetwork/charon"` |
| `image.pullPolicy` |  | `"IfNotPresent"` |
| `image.tag` |  | `"v0.11.0"` |
| `imagePullSecrets` |  | `[]` |
| `nameOverride` |  | `""` |
| `fullnameOverride` |  | `""` |
| `serviceAccount.create` |  | `true` |
| `serviceAccount.annotations` |  | `{}` |
| `serviceAccount.name` |  | `""` |
| `podAnnotations` |  | `{}` |
| `podSecurityContext.fsGroup` |  | `1000` |
| `podSecurityContext.runAsUser` |  | `1000` |
| `securityContext` |  | `null` |
| `service.svcHeadless` |  | `false` |
| `service.type` |  | `"ClusterIP"` |
| `service.ports.validatorApi.name` |  | `"validator-api"` |
| `service.ports.validatorApi.port` |  | `3600` |
| `service.ports.validatorApi.protocol` |  | `"TCP"` |
| `service.ports.validatorApi.targetPort` |  | `3600` |
| `service.ports.p2pTcp.name` |  | `"p2p-tcp"` |
| `service.ports.p2pTcp.port` |  | `3610` |
| `service.ports.p2pTcp.protocol` |  | `"TCP"` |
| `service.ports.p2pTcp.targetPort` |  | `3610` |
| `service.ports.monitoring.name` |  | `"monitoring"` |
| `service.ports.monitoring.port` |  | `3620` |
| `service.ports.monitoring.protocol` |  | `"TCP"` |
| `service.ports.monitoring.targetPort` |  | `3620` |
| `service.ports.p2pUdp.name` |  | `"p2p-udp"` |
| `service.ports.p2pUdp.port` |  | `3630` |
| `service.ports.p2pUdp.protocol` |  | `"UDP"` |
| `service.ports.p2pUdp.targetPort` |  | `3630` |
| `resources` |  | `{}` |
| `nodeSelector` |  | `{}` |
| `tolerations` |  | `{}` |
| `affinity` |  | `{}` |
| `sessionAffinity.enabled` |  | `false` |
| `sessionAffinity.timeoutSeconds` |  | `86400` |
| `priorityClassName` |  | `""` |
| `livenessProbe.httpGet.path` |  | `"/metrics"` |
| `livenessProbe.httpGet.port` |  | `3620` |
| `livenessProbe.initialDelaySeconds` |  | `10` |
| `livenessProbe.periodSeconds` |  | `5` |
| `readinessProbe.httpGet.path` |  | `"/metrics"` |
| `readinessProbe.httpGet.port` |  | `3620` |
| `readinessProbe.initialDelaySeconds` |  | `5` |
| `readinessProbe.periodSeconds` |  | `3` |
| `podDisruptionBudget.enabled` |  | `false` |
| `podDisruptionBudget.maxUnavailable` |  | `1` |
| `charon.config.validatorApiAddress` |  | `"0.0.0.0:3600"` |
| `charon.config.p2pTcpAddress` |  | `"0.0.0.0:3610"` |
| `charon.config.monitoringAddress` |  | `"0.0.0.0:3620"` |
| `charon.config.p2pUdpAddress` |  | `"0.0.0.0:3630"` |
| `charon.config.p2pBootnodeRelay` |  | `true` |
| `charon.config.p2pBootnodes` |  | `"http://bootnode.lb.gcp.obol.tech:3640/enr"` |
| `charon.config.beaconNodeEndpoints` |  | `""` |
| `charon.config.charonLockFile` |  | `"/charon/cluster-lock/cluster-lock.json"` |
| `charon.config.privateKeyFile` |  | `"/charon/charon-enr-private-key/charon-enr-private-key"` |
| `charon.config.logLevel` |  | `"debug"` |
| `charon.config.p2pExternalHostname` |  | `""` |
| `charon.config.noVerify` |  | `true` |
| `charon.config.jaegerAddress` |  | `"jaeger:6831"` |
| `charon.config.jaegerService` |  | `"charon"` |
| `charon.config.jaegerServicelogLevel` |  | `"debug"` |
| `charon.secrets.validatorKeys` |  | `"validators"` |
| `charon.secrets.enrPrivateKey` |  | `"charon-enr-private-key"` |
| `charon.secrets.clusterlock` |  | `"cluster-lock"` |
