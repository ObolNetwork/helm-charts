Obol App
===========

![Version: 0.2.0](https://img.shields.io/badge/Version-0.2.0-informational?style=flat-square) ![Type: application](https://img.shields.io/badge/Type-application-informational?style=flat-square) ![AppVersion: latest](https://img.shields.io/badge/AppVersion-latest-informational?style=flat-square)

A chart for running any Docker image within the Obol Stack.

Try it with:

```sh
# Add the Obol Chart Repo
helm repo add obol https://obolnetwork.github.io/helm-charts/

# Specify the docker image you want to run
export DOCKER_IMAGE="busybox"

# Install it with `helm install`
helm install obol/obol-app --generate-name --name-template "obol-app-$DOCKER_IMAGE-{{ now | date \"20060102\" }}" --namespace "obol-app-$DOCKER_IMAGE" --create-namespace --set-string image.repository=$DOCKER_IMAGE
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
| image.auth.enabled | bool | `false` |  |
| image.auth.secretName | string | `""` |  |
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
| obol.environment.custom | list | `[]` |  |
| obol.stack.enabled | bool | `true` |  |
| obol.stack.ethRpcUrl | string | `"http://rpc.l1.svc.cluster.local"` |  |
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