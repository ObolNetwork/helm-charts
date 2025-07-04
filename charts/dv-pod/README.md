
Charon Cluster
===========

![Version: 0.3.4](https://img.shields.io/badge/Version-0.3.4-informational?style=flat-square) ![Type: application](https://img.shields.io/badge/Type-application-informational?style=flat-square) ![AppVersion: 1.4.3](https://img.shields.io/badge/AppVersion-1.4.3-informational?style=flat-square)

Charon is an open-source Ethereum Distributed validator middleware written in golang. This chart deploys a full Charon cluster.

**Homepage:** <https://obol.tech/>

## Source Code

* <https://github.com/ObolNetwork/charon>

## Requirements

| Repository | Name | Version |
|------------|------|---------|
| https://ethpandaops.github.io/ethereum-helm-charts | erigon | 1.0.12 |
| https://ethpandaops.github.io/ethereum-helm-charts | lighthouse | 1.1.5 |

## Values

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| affinity | object | `{}` | Affinity for pod assignment # ref: https://kubernetes.io/docs/concepts/configuration/assign-pod-node/#affinity-and-anti-affinity # # Example: # affinity: #   podAntiAffinity: #     requiredDuringSchedulingIgnoredDuringExecution: #     - labelSelector: #         matchExpressions: #         - key: app.kubernetes.io/name #           operator: In #           values: #           - charon #       topologyKey: kubernetes.io/hostname # |
| affinity | object | `{}` | Affinity for pod assignment # ref: https://kubernetes.io/docs/concepts/configuration/assign-pod-node/#affinity-and-anti-affinity # # Example: # affinity: #   podAntiAffinity: #     requiredDuringSchedulingIgnoredDuringExecution: #     - labelSelector: #         matchExpressions: #         - key: app.kubernetes.io/name #           operator: In #           values: #           - charon #       topologyKey: kubernetes.io/hostname # |
| centralMonitoring | object | `{"enabled":false,"promEndpoint":"https://vm.monitoring.gcp.obol.tech/write","token":""}` | Central Monitoring |
| centralMonitoring.enabled | bool | `false` | Specifies whether central monitoring should be enabled |
| centralMonitoring.promEndpoint | string | `"https://vm.monitoring.gcp.obol.tech/write"` | https endpoint to obol central prometheus  |
| centralMonitoring.token | string | `""` | The authentication token to the central prometheus |
| charon.config.privateKeyFile | string | `"/data/charon_shared_enr_private_key"` | Path within EACH Charon container where the SHARED ENR private key file will be mounted. |
| charon.dkgSidecar | object | `{"apiEndpoint":"https://api.obol.tech","enabled":true,"image":{"pullPolicy":"IfNotPresent","repository":"obolnetwork/charon","tag":"v1.4.2"},"initialRetryDelaySeconds":10,"maxRetryDelaySeconds":300,"pageLimit":10,"resources":{},"retryDelayFactor":2,"retryDelaySeconds":10,"serviceAccount":{"create":true}}` | Configuration for the Orchestrator init container This init container handles polling for signed cluster definitions and will later manage the DKG process. |
| charon.dkgSidecar.apiEndpoint | string | `"https://api.obol.tech"` | API endpoint for the Obol network to fetch cluster definitions |
| charon.dkgSidecar.image.repository | string | `"obolnetwork/charon"` | Image repository for the poller (must include sh, curl, jq, and eventually charon CLI for DKG) This should be an image containing sh, curl, jq, and the charon CLI. |
| charon.dkgSidecar.initialRetryDelaySeconds | int | `10` | Initial delay in seconds before the first retry of a polling cycle. |
| charon.dkgSidecar.maxRetryDelaySeconds | int | `300` | Maximum delay in seconds for exponential backoff between polling cycles. |
| charon.dkgSidecar.pageLimit | int | `10` | Page limit for API calls when fetching cluster definitions |
| charon.dkgSidecar.resources | object | `{}` | Resources for the cluster poller init container |
| charon.dkgSidecar.retryDelayFactor | int | `2` | Factor by which the retry delay increases after each polling cycle (e.g., 2 for doubling). |
| charon.dkgSidecar.retryDelaySeconds | int | `10` | Delay in seconds between polling retries |
| charon.dkgSidecar.serviceAccount | object | `{"create":true}` | Service account settings for test pods |
| charon.enr.existingSecret | object | `{"dataKey":"private-key","name":""}` | Point to an existing Kubernetes secret that holds the shared ENR private key. If 'privateKey' above is not set and this 'existingSecret.name' is provided, 'generate' is ignored. |
| charon.enr.generate | object | `{"enabled":true,"image":{"pullPolicy":"IfNotPresent","repository":"obolnetwork/charon","tag":"v1.4.2"},"kubectlImage":{"pullPolicy":"IfNotPresent","repository":"bitnami/kubectl","tag":"latest"}}` | Enable automatic generation of a shared ENR private key. This is active only if 'privateKey' and 'existingSecret.name' are NOT set. The generated key will be stored in a secret (e.g., "{{ .Release.Name }}-charon-enr-key")  with data keys 'private-key' (for the hex key) and 'public-enr' (for the ENR string). |
| charon.enr.generate.kubectlImage | object | `{"pullPolicy":"IfNotPresent","repository":"bitnami/kubectl","tag":"latest"}` | Image to use for kubectl operations within the ENR generation job This image must contain a compatible kubectl binary. |
| charon.enr.privateKey | string | `""` | Provide the shared ENR private key directly (hex format, e.g., 0x...).  If set, 'generate' and 'existingSecret' are ignored. |
| charon.enrJob.enabled | bool | `true` | Enable or disable the Kubernetes Job that generates/manages the ENR. |
| charon.operatorAddress | string | `""` | The Ethereum address of this operator. This MUST be provided by the user. |
| config.LockFile | string | `"/charon/cluster-lock.json"` | The path to the cluster lock file defining distributed validator cluster. (default ".charon/cluster-lock.json") |
| config.beaconNodeEndpoints | string | `"http://localhost:9999"` | Comma separated list of one or more beacon node endpoint URLs. |
| config.builderApi | string | `""` | Enables the builder api. Will only produce builder blocks. Builder API must also be enabled on the validator client. Beacon node must be connected to a builder-relay to access the builder network. |
| config.charonInternalMonitoringPort | int | `3625` | Specific internal monitoring port for Charon container to avoid sidecar conflicts. |
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
| erigon.enabled | bool | `true` |  |
| erigon.extraArgs[0] | string | `"--chain=hoodi"` |  |
| erigon.extraArgs[1] | string | `"--externalcl"` |  |
| erigon.persistence.enabled | bool | `true` |  |
| erigon.persistence.size | string | `"200Gi"` |  |
| fullnameOverride | string | `""` | Provide a name to substitute for the full names of resources |
| image | object | `{"pullPolicy":"IfNotPresent","repository":"obolnetwork/charon","tag":"v1.4.3"}` | Charon image repository, pull policy, and tag version |
| imagePullSecrets | list | `[]` | Credentials to fetch images from private registry # ref: https://kubernetes.io/docs/tasks/configure-pod-container/pull-image-private-registry/ |
| lighthouse.enabled | bool | `true` |  |
| lighthouse.extraArgs[0] | string | `"--execution-endpoint=https://hoodi.beaconstate.info"` |  |
| lighthouse.extraArgs[1] | string | `"--network=hoodi"` |  |
| livenessProbe | object | `{"enabled":false,"httpGet":{"path":"/livez"},"initialDelaySeconds":10,"periodSeconds":5}` | Configure liveness probes # ref: https://kubernetes.io/docs/tasks/configure-pod-container/configure-liveness-readiness-startup-probes/ |
| nameOverride | string | `""` | Provide a name in place of lighthouse for `app:` labels |
| nodeSelector | object | `{}` | Node labels for pod assignment # ref: https://kubernetes.io/docs/user-guide/node-selection/ |
| nodeSelector | object | `{}` | Node selector for pod assignment Ref: https://kubernetes.io/docs/user-guide/node-selection/ |
| persistence | object | `{"accessModes":["ReadWriteOnce"],"enabled":true,"size":"1Gi"}` | Persistence configuration for DKG artifacts and charon data |
| persistence.accessModes | list | `["ReadWriteOnce"]` | Access modes for the PVC. Must be a list. Default: ["ReadWriteOnce"]. |
| persistence.enabled | bool | `true` | Enable persistence using a PersistentVolumeClaim. |
| persistence.size | string | `"1Gi"` | Size of the PVC. |
| podAnnotations | object | `{}` | Pod annotations |
| podDisruptionBudget | object | `{"enabled":true,"minAvailable":""}` | Enable pod disruption budget # ref: https://kubernetes.io/docs/tasks/run-application/configure-pdb |
| podDisruptionBudget | object | `{"enabled":true,"minAvailable":""}` | Enable pod disruption budget # ref: https://kubernetes.io/docs/tasks/run-application/configure-pdb |
| priorityClassName | string | `""` | Used to assign priority to pods # ref: https://kubernetes.io/docs/concepts/configuration/pod-priority-preemption/ |
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
| secrets | object | `{"clusterlock":"cluster-lock","enrPrivateKey":"charon-enr-private-key","validatorKeys":"validator-keys"}` | Kubernetes secrets names that might be used as suffixes or for other purposes. For the shared ENR, the secret name is either defined in 'charon.enr.existingSecret.name'  or generated by the ENR job (e.g., {{ .Release.Name }}-charon-enr-key). The 'enrPrivateKey' field below is NOT directly used for the shared ENR secret name in this model. |
| secrets.clusterlock | string | `"cluster-lock"` | Name or suffix for the charon cluster lock secret |
| secrets.enrPrivateKey | string | `"charon-enr-private-key"` | This field is less relevant for the SHARED ENR model. Retained for other potential uses or legacy compatibility. For shared ENR, see 'charon.enr' section above. |
| secrets.validatorKeys | string | `"validator-keys"` | Suffix or name component for validator keys secrets (if applicable, distinct from ENR) |
| securityContext | object | See `values.yaml` | The security context for pods |
| service | object | `{"clusterIP":"None","ports":{"monitoring":{"name":"monitoring","port":3620,"protocol":"TCP","targetPort":3620},"p2pTcp":{"name":"p2p-tcp","port":3610,"protocol":"TCP","targetPort":3610},"validatorApi":{"name":"validator-api","port":3600,"protocol":"TCP","targetPort":3600}}}` | Charon service ports |
| service.clusterIP | string | `"None"` | Headless service to create DNS for each statefulset instance |
| serviceAccount | object | `{"annotations":{},"enabled":true,"name":""}` | Service account # ref: https://kubernetes.io/docs/tasks/configure-pod-container/configure-service-account/ |
| serviceAccount.annotations | object | `{}` | Annotations to add to the service account |
| serviceAccount.enabled | bool | `true` | Specifies whether a service account should be created |
| serviceAccount.name | string | `""` | The name of the service account to use. If not set and create is true, a name is generated using the default template |
| serviceMonitor | object | `{"annotations":{},"enabled":false,"interval":"1m","labels":{},"namespace":null,"path":"/metrics","relabelings":[],"scheme":"http","scrapeTimeout":"30s","tlsConfig":{}}` | Prometheus Service Monitor # ref: https://github.com/coreos/prometheus-operator |
| serviceMonitor.annotations | object | `{}` | Additional ServiceMonitor annotations |
| serviceMonitor.enabled | bool | `false` | If true, a ServiceMonitor CRD is created for a prometheus operator. https://github.com/coreos/prometheus-operator TODO: SWITCH BACK TO ON FOR PRODUCTION |
| serviceMonitor.interval | string | `"1m"` | ServiceMonitor scrape interval |
| serviceMonitor.labels | object | `{}` | Additional ServiceMonitor labels |
| serviceMonitor.namespace | string | `nil` | Alternative namespace for ServiceMonitor |
| serviceMonitor.path | string | `"/metrics"` | Path to scrape |
| serviceMonitor.relabelings | list | `[]` | ServiceMonitor relabelings |
| serviceMonitor.scheme | string | `"http"` | ServiceMonitor scheme |
| serviceMonitor.scrapeTimeout | string | `"30s"` | ServiceMonitor scrape timeout |
| serviceMonitor.tlsConfig | object | `{}` | ServiceMonitor TLS configuration |
| tests | object | `{"dkgSidecar":{"enabled":true,"freshState":{"enabled":true,"mockEnr":"enr:-Ku4QEXAMPLEOPERATORAENRFROMTHEMOCKAPISERVERPLEASEMODIFYPREVIOUSVALUE"},"hostNetwork":false,"mockApi":{"image":{"pullPolicy":"Always"},"port":3001},"operatorAddress":"0x3D1f0598943239806A251899016EAf4920d4726d","podEnrToFind":"enr:-Ku4QEXAMPLEOPERATORAENRFROMTHEMOCKAPISERVERPLEASEMODIFYPREVIOUSVALUE","serviceAccount":{"create":true}}}` | Configuration for running Helm tests. These values are typically only used when `helm test` is run. |
| tests.dkgSidecar | object | `{"enabled":true,"freshState":{"enabled":true,"mockEnr":"enr:-Ku4QEXAMPLEOPERATORAENRFROMTHEMOCKAPISERVERPLEASEMODIFYPREVIOUSVALUE"},"hostNetwork":false,"mockApi":{"image":{"pullPolicy":"Always"},"port":3001},"operatorAddress":"0x3D1f0598943239806A251899016EAf4920d4726d","podEnrToFind":"enr:-Ku4QEXAMPLEOPERATORAENRFROMTHEMOCKAPISERVERPLEASEMODIFYPREVIOUSVALUE","serviceAccount":{"create":true}}` | The operator address to use for DKG sidecar tests. This should be a valid Ethereum address (0x...). |
| tests.dkgSidecar.freshState | object | `{"enabled":true,"mockEnr":"enr:-Ku4QEXAMPLEOPERATORAENRFROMTHEMOCKAPISERVERPLEASEMODIFYPREVIOUSVALUE"}` | Configuration for the 'FRESH' state test |
| tests.dkgSidecar.freshState.mockEnr | string | `"enr:-Ku4QEXAMPLEOPERATORAENRFROMTHEMOCKAPISERVERPLEASEMODIFYPREVIOUSVALUE"` | Mock ENR value to be used by the fresh state test ConfigMap. Replace with a valid ENR string if your test specifically requires one for the FRESH state mock. |
| tests.dkgSidecar.hostNetwork | bool | `false` | Host network setting for dkgSidecar test pods |
| tests.dkgSidecar.serviceAccount | object | `{"create":true}` | Service account settings for test pods |
| tolerations | object | `{}` | Tolerations for pod assignment # ref: https://kubernetes.io/docs/concepts/configuration/taint-and-toleration/ |
| tolerations | object | `{}` | Tolerations for pod assignment # ref: https://kubernetes.io/docs/concepts/configuration/taint-and-toleration/ |
| updateStrategy | string | `"RollingUpdate"` | allows you to configure and disable automated rolling updates for containers, labels, resource request/limits, and annotations for the Pods in a StatefulSet. |
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
You have the following charon artifacts created as k8s secrets per each charon node:
- `<cluster-name>-<node-index>-validators` i.e `charon-cluster-0-validators`
- `<cluster-name>-<node-index>-charon-enr-private-key` i.e `charon-cluster-0-charon-enr-private-key`
The cluster lock is a single secret for the whole cluster:
- `cluster-lock`

e.g. with node0:
```console
kubectl create secret generic charon-enr-private-key --from-file=cluster/node0/charon-enr-private-key
kubectl create secret generic cluster-lock --from-file=node0/cluster-lock.json
kubectl create secret generic validator-keys --from-file=keystore-0.json=cluster/node0/validator_keys/keystore-0.json --from-file=keystore-0.txt=cluster/node0/validator_keys/keystore-0.txt

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
