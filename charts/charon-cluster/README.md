
Charon Cluster
===========

![Version: 0.2.0](https://img.shields.io/badge/Version-0.2.0-informational?style=flat-square) ![Type: application](https://img.shields.io/badge/Type-application-informational?style=flat-square) ![AppVersion: 0.19.0](https://img.shields.io/badge/AppVersion-0.19.0-informational?style=flat-square)

Charon is an open-source Ethereum Distributed validator middleware written in golang. This chart deploys a full Charon cluster.

**Homepage:** <https://obol.tech/>

## Source Code

* <https://github.com/ObolNetwork/charon>

## Values

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| affinity | object | `{}` | Affinity for pod assignment # ref: https://kubernetes.io/docs/concepts/configuration/assign-pod-node/#affinity-and-anti-affinity # # Example: # affinity: #   podAntiAffinity: #     requiredDuringSchedulingIgnoredDuringExecution: #     - labelSelector: #         matchExpressions: #         - key: app.kubernetes.io/name #           operator: In #           values: #           - charon #       topologyKey: kubernetes.io/hostname # |
| centralMonitoring | object | `{"enabled":false,"promEndpoint":"https://vm.monitoring.gcp.obol.tech/write","token":""}` | Central Monitoring |
| centralMonitoring.enabled | bool | `false` | Specifies whether central monitoring should be enabled |
| centralMonitoring.promEndpoint | string | `"https://vm.monitoring.gcp.obol.tech/write"` | https endpoint to obol central prometheus  |
| centralMonitoring.token | string | `""` | The authentication token to the central prometheus |
| clusterSize | int | `4` | The number of charon nodes in the cluster. Minimum is 4 |
| clusterThreshold | int | `3` | Cluster threshold required for signature reconstruction. Defaults to ceil(n*2/3) if zero. Warning, non-default values decrease security. |
| config.LockFile | string | `"/charon/cluster-lock.json"` | The path to the cluster lock file defining distributed validator cluster. (default ".charon/cluster-lock.json") |
| config.beaconNodeEndpoints | string | `""` | Comma separated list of one or more beacon node endpoint URLs. |
| config.builderApi | string | `""` | Enables the builder api. Will only produce builder blocks. Builder API must also be enabled on the validator client. Beacon node must be connected to a builder-relay to access the builder network. |
| config.directConnectionEnabled | string | `"true"` | If enabled, it will set p2pExternalHostname value to the pod name and enable direct connection between cluster nodes |
| config.featureSet | string | `"stable"` | Minimum feature set to enable by default: alpha, beta, or stable. Warning: modify at own risk. (default "stable") |
| config.featureSetDisable | string | `""` | Comma-separated list of features to disable, overriding the default minimum feature set. |
| config.featureSetEnable | string | `""` | Comma-separated list of features to enable, overriding the default minimum feature set. |
| config.jaegerAddress | string | `"jaeger:6831"` | Listening address for jaeger tracing. |
| config.jaegerService | string | `""` | Service name used for jaeger tracing. |
| config.logFormat | string | `"json"` | Log format; console, logfmt or json (default "console") |
| config.logLevel | string | `"info"` | Log level; debug, info, warn or error (default "info") |
| config.lokiAddresses | string | `""` | Enables sending of logfmt structured logs to these Loki log aggregation server addresses. This is in addition to normal stderr logs. |
| config.lokiService | string | `""` | Service label sent with logs to Loki. |
| config.monitoringAddress | string | `"0.0.0.0:3620"` | Listening address (ip and port) for the monitoring API (prometheus, pprof). (default "127.0.0.1:3620") |
| config.noVerify | bool | `false` | Disables cluster definition and lock file verification. |
| config.p2pAllowlist | string | `""` | Comma-separated list of CIDR subnets for allowing only certain peer connections. Example: 192.168.0.0/16 would permit connections to peers on your local network only. The default is to accept all connections. |
| config.p2pDenylist | string | `""` | Comma-separated list of CIDR subnets for disallowing certain peer connections. Example: 192.168.0.0/16 would disallow connections to peers on your local network. The default is to accept all connections. |
| config.p2pDisableReuseport | string | `""` | Disables TCP port reuse for outgoing libp2p connections. |
| config.p2pExternalHostname | string | `""` | The DNS hostname advertised by libp2p. This may be used to advertise an external DNS. |
| config.p2pExternalIp | string | `""` | The IP address advertised by libp2p. This may be used to advertise an external IP. |
| config.p2pRelays | string | `""` | Comma-separated list of libp2p relay URLs or multiaddrs. (default [https://0.relay.obol.tech/enr]) |
| config.p2pTcpAddress | string | `"0.0.0.0:3610"` | Comma-separated list of listening TCP addresses (ip and port) for libP2P traffic. Empty default doesn't bind to local port therefore only supports outgoing connections. |
| config.simnetBeaconMock | string | `""` | Enables an internal mock beacon node for running a simnet. |
| config.simnetValidatorKeysDir | string | `""` | The directory containing the simnet validator key shares. (default ".charon/validator_keys") |
| config.simnetValidatorMock | string | `""` | Enables an internal mock validator client when running a simnet. Requires simnet-beacon-mock. |
| config.syntheticBlockProposals | string | `""` | Enables additional synthetic block proposal duties. Used for testing of rare duties. |
| config.validatorApiAddress | string | `"0.0.0.0:3600"` | Listening address (ip and port) for validator-facing traffic proxying the beacon-node API. (default "127.0.0.1:3600") |
| containerSecurityContext | object | See `values.yaml` | The security context for containers |
| fullnameOverride | string | `""` | Provide a name to substitute for the full names of resources |
| image | object | `{"pullPolicy":"IfNotPresent","repository":"obolnetwork/charon","tag":"v0.19.0"}` | Charon image ropsitory, pull policy, and tag version |
| imagePullSecrets | list | `[]` | Credentials to fetch images from private registry # ref: https://kubernetes.io/docs/tasks/configure-pod-container/pull-image-private-registry/ |
| livenessProbe | object | `{"enabled":false,"httpGet":{"path":"/livez"},"initialDelaySeconds":10,"periodSeconds":5}` | Configure liveness probes # ref: https://kubernetes.io/docs/tasks/configure-pod-container/configure-liveness-readiness-startup-probes/ |
| nameOverride | string | `""` | Provide a name in place of lighthouse for `app:` labels |
| nodeSelector | object | `{}` | Node labels for pod assignment # ref: https://kubernetes.io/docs/user-guide/node-selection/ |
| podAnnotations | object | `{}` | Pod annotations |
| podDisruptionBudget | object | `{"enabled":true,"minAvailable":""}` | Enable pod disruption budget # ref: https://kubernetes.io/docs/tasks/run-application/configure-pdb |
| priorityClassName | string | `""` | Used to assign priority to pods # ref: https://kubernetes.io/docs/concepts/configuration/pod-priority-preemption/ |
| rbac | object | `{"clusterRules":[{"apiGroups":[""],"resources":["nodes"],"verbs":["get","list","watch"]}],"enabled":true,"name":"","rules":[{"apiGroups":[""],"resources":["services"],"verbs":["get","list","watch"]}]}` | RBAC configuration. # ref: https://kubernetes.io/docs/reference/access-authn-authz/rbac/ |
| rbac.clusterRules | list | `[{"apiGroups":[""],"resources":["nodes"],"verbs":["get","list","watch"]}]` | Required ClusterRole rules |
| rbac.clusterRules[0] | object | `{"apiGroups":[""],"resources":["nodes"],"verbs":["get","list","watch"]}` | Required to obtain the nodes external IP |
| rbac.enabled | bool | `true` | Specifies whether RBAC resources are to be created |
| rbac.name | string | `""` | The name of the cluster role to use. If not set and create is true, a name is generated using the fullname template |
| rbac.rules | list | `[{"apiGroups":[""],"resources":["services"],"verbs":["get","list","watch"]}]` | Required Role rules |
| rbac.rules[0] | object | `{"apiGroups":[""],"resources":["services"],"verbs":["get","list","watch"]}` | Required to get information about the serices nodePort. |
| readinessProbe | object | `{"enabled":false,"httpGet":{"path":"/readyz"},"initialDelaySeconds":5,"periodSeconds":3}` | Configure readiness probes # ref: https://kubernetes.io/docs/tasks/configure-pod-container/configure-liveness-readiness-startup-probes/ |
| resources | object | `{}` | Pod resources limits and requests |
| secrets | object | `{"clusterlock":"cluster-lock","enrPrivateKey":"charon-enr-private-key","validatorKeys":"validators"}` | Kubernetes secrets names |
| secrets.clusterlock | string | `"cluster-lock"` | charon cluster lock |
| secrets.enrPrivateKey | string | `"charon-enr-private-key"` | charon enr private key |
| secrets.validatorKeys | string | `"validators"` | validators keys |
| securityContext | object | See `values.yaml` | The security context for pods |
| service | object | `{"clusterIP":"None","ports":{"monitoring":{"name":"monitoring","port":3620,"protocol":"TCP","targetPort":3620},"p2pTcp":{"name":"p2p-tcp","port":3610,"protocol":"TCP","targetPort":3610},"validatorApi":{"name":"validator-api","port":3600,"protocol":"TCP","targetPort":3600}}}` | Charon service ports |
| service.clusterIP | string | `"None"` | Headless service to create DNS for each statefulset instance |
| serviceAccount | object | `{"annotations":{},"enabled":true,"name":""}` | Service account # ref: https://kubernetes.io/docs/tasks/configure-pod-container/configure-service-account/ |
| serviceAccount.annotations | object | `{}` | Annotations to add to the service account |
| serviceAccount.enabled | bool | `true` | Specifies whether a service account should be created |
| serviceAccount.name | string | `""` | The name of the service account to use. If not set and create is true, a name is generated using the default template |
| serviceMonitor | object | `{"annotations":{},"enabled":true,"interval":"1m","labels":{},"namespace":null,"path":"/metrics","relabelings":[],"scheme":"http","scrapeTimeout":"30s","tlsConfig":{}}` | Prometheus Service Monitor # ref: https://github.com/coreos/prometheus-operator |
| serviceMonitor.annotations | object | `{}` | Additional ServiceMonitor annotations |
| serviceMonitor.enabled | bool | `true` | If true, a ServiceMonitor CRD is created for a prometheus operator. https://github.com/coreos/prometheus-operator |
| serviceMonitor.interval | string | `"1m"` | ServiceMonitor scrape interval |
| serviceMonitor.labels | object | `{}` | Additional ServiceMonitor labels |
| serviceMonitor.namespace | string | `nil` | Alternative namespace for ServiceMonitor |
| serviceMonitor.path | string | `"/metrics"` | Path to scrape |
| serviceMonitor.relabelings | list | `[]` | ServiceMonitor relabelings |
| serviceMonitor.scheme | string | `"http"` | ServiceMonitor scheme |
| serviceMonitor.scrapeTimeout | string | `"30s"` | ServiceMonitor scrape timeout |
| serviceMonitor.tlsConfig | object | `{}` | ServiceMonitor TLS configuration |
| tolerations | object | `{}` | Tolerations for pod assignment # ref: https://kubernetes.io/docs/concepts/configuration/taint-and-toleration/ |
| updateStrategy | string | `"RollingUpdate"` | allows you to configure and disable automated rolling updates for containers, labels, resource request/limits, and annotations for the Pods in a StatefulSet. |

# How to use this chart

A distributed validator cluster is composed of the following containers:

- Single execution layer client
- Single consensus layer client
- Number of Distributed Validator clients [This chart]
- Number of Validator clients
- Prometheus, Grafana and Jaeger clients for monitoring this cluster.

![Distributed Validator Cluster](https://github.com/ObolNetwork/charon-distributed-validator-cluster/blob/main/DVCluster.png?raw=true)

## Prerequisites
You have the followin charon artifacts created as k8s secrets per each charon node:
- `<cluster-name>-<node-index>-validators` i.e `charon-cluster-0-validators`
- `<cluster-name>-<node-index>-charon-enr-private-key` i.e `charon-cluster-0-charon-enr-private-key`
The cluster lock is a single secret for the whole cluster:
- `cluster-lock`

List of secrets for a cluster `charon-cluster` with 4 nodes are:
```console
charon-cluster-0-charon-enr-private-key
charon-cluster-0-validators
charon-cluster-1-charon-enr-private-key
charon-cluster-1-validators
charon-cluster-2-charon-enr-private-key
charon-cluster-2-validators
charon-cluster-3-charon-enr-private-key
charon-cluster-3-validators
cluster-lock
```

## Add Obol's Helm Charts Repo

```sh
helm repo add obol https://obolnetwork.github.io/helm-charts
helm repo update
```
_See [helm repo](https://helm.sh/docs/helm/helm_repo/) for command documentation._

## Install the chart
Install a charon cluster `charon-cluster` with 4 nodes:
```sh
helm upgrade --install charon-cluster obol/charon-cluster \
  --set='clusterSize=4' \
  --set='config.beaconNodeEndpoints=<BEACON_NODES_ENDPOINTS>' \
  --create-namespace \
  --namespace $CHARON_NODE_NAMESPACE
```

## Connect the validator client
- Update each validator client to connect to charon node API endpoint instead of the beacon node endpoint `--beacon-node-api-endpoint="http://CHARON_NODE_SERVICE_NAME:3600"`
- Mount each of the `<cluster-name>-<node-index>-validators` k8s secrets to the validator client validators folder.

Example of a single teku deployment that pairs with the charon-cluster node `charon-cluster-0`
```yaml
---
apiVersion: apps/v1
kind: Deployment
metadata:
  labels:
    app: charon-cluster-0-teku
  name: charon-cluster-0-teku
  namespace: charon-cluster
spec:
  replicas: 1
  selector:
    matchLabels:
      app: charon-cluster-0-teku
  strategy:
    type: Recreate
  template:
    metadata:
      labels:
        app: charon-cluster-0-teku
    spec:
      securityContext:
        fsGroup: 1000
        runAsUser: 1000
      initContainers:
        - name: init-chown
          image: busybox
          securityContext:
            runAsUser: 0
          command:
            - sh
            - -ac
            - >
              rm -rf /data/teku/validator_keys 2>/dev/null || true;
              mkdir -p /data/teku/validator_keys;
              cp /validator_keys/* /data/teku/validator_keys;
              chown -R 1000:1000 /data/teku;
          volumeMounts:
            - name: data
              mountPath: /data/teku
            - name: validators
              mountPath: "/validator_keys"
      containers:
        - name: charon-cluster-0-teku
          image: consensys/teku:latest
          command:
            - sh
            - -ace
            - |
              /opt/teku/bin/teku vc \
              --network=auto \
              --log-destination=console \
              --data-base-path=/data/teku \
              --metrics-enabled=true \
              --metrics-host-allowlist="*" \
              --metrics-interface="0.0.0.0" \
              --metrics-port="8008" \
              --validator-keys="/data/teku/validator_keys:/data/teku/validator_keys" \
              --validators-graffiti="Obol Distributed Validator" \
              --beacon-node-api-endpoint="http://charon-cluster-0.charon-cluster.charon-cluster.svc.cluster.local:3600" \
              --validators-proposer-default-fee-recipient="0x9FD17880D4F5aE131D62CE6b48dF7ba7D426a410";
          volumeMounts:
            - name: data
              mountPath: /data/teku
      volumes:
        - name: validators
          projected:
            sources:
            - secret:
                name: charon-cluster-validators
        - name: data
          emptyDir: {}
```

## Uninstall the Chart
To uninstall and delete the `charon-cluster`:
```sh
helm uninstall charon-cluster
```
The command removes all the Kubernetes components associated with the chart and deletes the release.
