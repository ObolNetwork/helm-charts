{{/*
Expand the name of the chart.
*/}}
{{- define "dv-pod.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Expand the release name of the chart.
*/}}
{{- define "release.name" -}}
{{- default .Release.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "dv-pod.fullname" -}}
{{- if .Values.fullnameOverride }}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- $name := default .Chart.Name .Values.nameOverride }}
{{- if contains $name .Release.Name }}
{{- .Release.Name | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" }}
{{- end }}
{{- end }}
{{- end }}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "dv-pod.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "dv-pod.labels" -}}
helm.sh/chart: {{ include "dv-pod.chart" . }}
{{ include "dv-pod.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "dv-pod.selectorLabels" -}}
app.kubernetes.io/name: {{ include "dv-pod.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Create the name of the service account to use
*/}}
{{- define "dv-pod.serviceAccountName" -}}
{{- if and (.Values.serviceAccount.enabled) (.Values.serviceAccount.name) }}
{{- default .Values.serviceAccount.name }}
{{- else }}
{{- default .Release.Name }}
{{- end }}
{{- end }}

{{/*
Per-release ENR secret name used for new installs.
*/}}
{{- define "dv-pod.enrReleaseSecretName" -}}
{{- printf "%s-enr-key" (include "dv-pod.fullname" .) | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Name of the Secret holding this node's ENR private key (its charon identity).
An existing identity is never replaced, and two releases never share one:
1. charon.enr.existingSecret.name, if set (explicit).
2. Else, on upgrade, whatever Secret this release's StatefulSet already mounts (sticky identity).
3. Else the legacy shared name (secrets.defaultEnrPrivateKey, "charon-enr-private-key") if that Secret
   exists in the namespace and no other StatefulSet mounts it (pre-created for import, or a pre-0.22 install).
4. Else "<fullname>-enr-key".
Steps 2 and 3 use `lookup`, which is empty under `helm template`/`--dry-run`/GitOps renderers; there the
name falls through to step 4 and the ENR hook Job performs the same migration check at runtime, copying
the legacy identity into "<fullname>-enr-key" instead of generating a new one.
*/}}
{{- define "dv-pod.enrSecretName" -}}
{{- $release := include "dv-pod.enrReleaseSecretName" . -}}
{{- $legacy := .Values.secrets.defaultEnrPrivateKey -}}
{{- $sts := include "dv-pod.fullname" . -}}
{{- $name := "" -}}
{{- if .Values.charon.enr.existingSecret.name -}}
{{- $name = .Values.charon.enr.existingSecret.name -}}
{{- else -}}
{{- $own := lookup "apps/v1" "StatefulSet" .Release.Namespace $sts -}}
{{- if $own -}}
{{- range $own.spec.template.spec.volumes -}}
{{- if and (eq .name "charon-enr-private-key") .secret -}}
{{- $name = .secret.secretName -}}
{{- end -}}
{{- end -}}
{{- end -}}
{{- if and (not $name) $legacy (ne $legacy $release) (lookup "v1" "Secret" .Release.Namespace $legacy) -}}
{{- $claimed := false -}}
{{- $all := lookup "apps/v1" "StatefulSet" .Release.Namespace "" -}}
{{- range ($all.items | default list) -}}
{{- if ne .metadata.name $sts -}}
{{- range .spec.template.spec.volumes -}}
{{- if and (eq .name "charon-enr-private-key") .secret (eq .secret.secretName $legacy) -}}
{{- $claimed = true -}}
{{- end -}}
{{- end -}}
{{- end -}}
{{- end -}}
{{- if not $claimed -}}
{{- $name = $legacy -}}
{{- end -}}
{{- end -}}
{{- end -}}
{{- $name | default $release -}}
{{- end -}}

{{/*
Name of the ConfigMap holding this node's public ENR (key "enr"), written by the ENR hook Job.
Lets agents and humans read the ENR without access to Secrets.
*/}}
{{- define "dv-pod.enrConfigMapName" -}}
{{- printf "%s-enr" (include "dv-pod.fullname" .) | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Name of the DKG status ConfigMap written by the sidecar.
*/}}
{{- define "dv-pod.statusConfigMapName" -}}
{{- printf "%s-dkg-status" (include "dv-pod.fullname" .) | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
"true" when the sidecar should publish DKG status to the status ConfigMap. Needs the chart's
ServiceAccount and RBAC, since the sidecar authenticates with the pod's service account token.
*/}}
{{- define "dv-pod.statusEnabled" -}}
{{- if and .Values.dkg.status.enabled .Values.charon.dkgSidecar.enabled .Values.serviceAccount.enabled .Values.rbac.enabled -}}
true
{{- end -}}
{{- end -}}

{{/*
Normalise a boolean-ish value: true, "true" -> "true"; false, "false", "", null -> "".
Older values files pass charon.builderApi / directConnectionEnabled as strings.
*/}}
{{- define "dv-pod.truthy" -}}
{{- if kindIs "bool" . -}}
{{- if . }}true{{ end -}}
{{- else if kindIs "string" . -}}
{{- if eq (lower (trim .)) "true" }}true{{ end -}}
{{- end -}}
{{- end -}}

{{/*
Effective participation mode. `auto` keeps the pre-0.22 inference:
configMaps.clusterLock -> lock, charon.lockHash -> lockHash, any dkg.definition source -> definition,
otherwise launchpad (poll the Obol API by operator address).
*/}}
{{- define "dv-pod.mode" -}}
{{- $mode := .Values.mode | default "auto" -}}
{{- if ne $mode "auto" -}}
{{- $mode -}}
{{- else if .Values.configMaps.clusterLock -}}
lock
{{- else if .Values.charon.lockHash -}}
lockHash
{{- else if or .Values.dkg.definition.configHash .Values.dkg.definition.url .Values.dkg.definition.configMap -}}
definition
{{- else -}}
launchpad
{{- end -}}
{{- end -}}

{{/*
"true" when this release may run a DKG ceremony (launchpad or definition mode, with the sidecar enabled).
*/}}
{{- define "dv-pod.runsDkg" -}}
{{- if and .Values.charon.dkgSidecar.enabled (has (include "dv-pod.mode" .) (list "launchpad" "definition")) -}}
true
{{- end -}}
{{- end -}}

{{/*
DEFINITION_SOURCE for the sidecar (empty = leave the sidecar default, "auto").
*/}}
{{- define "dv-pod.definitionSource" -}}
{{- $mode := include "dv-pod.mode" . -}}
{{- if eq $mode "definition" -}}
{{- if .Values.dkg.definition.configHash -}}
config-hash
{{- else if .Values.dkg.definition.url -}}
url
{{- else if .Values.dkg.definition.configMap -}}
file
{{- end -}}
{{- else if and (eq $mode "launchpad") (eq (.Values.mode | default "auto") "launchpad") -}}
operator
{{- end -}}
{{- end -}}

{{/*
Obol API base URL (no trailing slash), used for `charon dkg --publish-address`.
*/}}
{{- define "dv-pod.apiBaseUrl" -}}
{{- .Values.charon.dkgSidecar.apiEndpoint | trimSuffix "/" | trimSuffix "/v1" -}}
{{- end -}}

{{/*
Sidecar image reference.
*/}}
{{- define "dv-pod.sidecarImage" -}}
{{- printf "%s:%s" .Values.charon.dkgSidecar.image.repository (.Values.charon.dkgSidecar.image.tag | default .Chart.AppVersion) -}}
{{- end -}}

{{/*
Projected service account token, mounted only into the sidecar containers that write the status
ConfigMap (the pod sets automountServiceAccountToken: false, so charon and the VC get no token).
*/}}
{{- define "dv-pod.kubeApiAccessVolume" -}}
- name: kube-api-access
  projected:
    defaultMode: 0444
    sources:
      - serviceAccountToken:
          path: token
          expirationSeconds: 3607
      - configMap:
          name: kube-root-ca.crt
          items:
            - key: ca.crt
              path: ca.crt
      - downwardAPI:
          items:
            - path: namespace
              fieldRef:
                fieldPath: metadata.namespace
{{- end -}}

{{- define "dv-pod.kubeApiAccessMount" -}}
- name: kube-api-access
  mountPath: /var/run/secrets/kubernetes.io/serviceaccount
  readOnly: true
{{- end -}}

{{/*
Return the data key for the ENR private key within the shared secret.
*/}}
{{- define "dv-pod.enrSecretDataKey" -}}
{{- .Values.charon.enr.existingSecret.privateKeyDataKey | default "charon-enr-private-key" -}}
{{- end -}}

{{/*
Return the data key for the ENR public key within the shared secret.
*/}}
{{- define "dv-pod.enrSecretPublicDataKey" -}}
{{- .Values.charon.enr.existingSecret.publicKeyDataKey | default "enr" -}}
{{- end -}}

{{/*
Determine if the ENR generation job should be created.
The job should be created if the ENR job is enabled AND either generation is enabled
or a private key is provided (the job derives the public ENR and creates the secret).
Note: The job will run even if an existing secret is specified, as it can handle incomplete secrets
(secrets with only private key missing the public ENR field)
*/}}
{{- define "dv-pod.shouldCreateEnrJob" -}}
{{- if and .Values.charon.enrJob.enabled (or .Values.charon.enr.generate.enabled .Values.charon.enr.privateKey) -}}
true
{{- end -}}
{{- end -}}

{{/*
Name of the hook Secret that carries charon.enr.privateKey to the ENR job.
*/}}
{{- define "dv-pod.enrProvidedKeySecretName" -}}
{{- printf "%s-enr-provided-key" (include "dv-pod.fullname" .) | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Create the name of the service account to use for tests
*/}}
{{- define "dv-pod.serviceAccountNameTest" -}}
{{- if and (.Values.serviceAccount.enabled) (.Values.serviceAccount.nameTest) }}
{{- default .Values.serviceAccount.nameTest }}
{{- else }}
{{- printf "%s-test" (include "dv-pod.fullname" .) }}
{{- end -}}
{{- end -}}

{{/*
Create comma-separated list of primary beacon node endpoints
*/}}
{{- define "dv-pod.beaconNodeEndpoints" -}}
{{- if .Values.charon.beaconNodeEndpoints -}}
{{- join "," .Values.charon.beaconNodeEndpoints -}}
{{- end -}}
{{- end -}}

{{/*
Create comma-separated list of fallback beacon node endpoints
*/}}
{{- define "dv-pod.fallbackBeaconNodeEndpoints" -}}
{{- if .Values.charon.fallbackBeaconNodeEndpoints -}}
{{- join "," .Values.charon.fallbackBeaconNodeEndpoints -}}
{{- else if .Values.charon.publicnodeFallback -}}
{{- $network := include "dv-pod.network" . -}}
{{- if eq $network "mainnet" -}}
https://ethereum-beacon-api.publicnode.com
{{- else -}}
{{- printf "https://ethereum-%s-beacon-api.publicnode.com" $network -}}
{{- end -}}
{{- end -}}
{{- end -}}

{{/*
Validate validator client type
*/}}
{{- define "dv-pod.validateValidatorClientType" -}}
{{- if .Values.validatorClient.enabled -}}
{{- $validTypes := list "lighthouse" "lodestar" "teku" "prysm" "nimbus" -}}
{{- $currentType := .Values.validatorClient.type -}}
{{- if not (has $currentType $validTypes) -}}
{{- fail (printf "ERROR: Invalid validator client type '%s'. Valid options are: %s" $currentType (join ", " $validTypes)) -}}
{{- end -}}
{{- end -}}
{{- end -}}

{{/*
Derive chainId from network name
Maps network name to the corresponding chainId for DKG and chain configuration
*/}}
{{- define "dv-pod.chainIdFromNetwork" -}}
{{- $network := .Values.network -}}
{{- if eq $network "mainnet" -}}
1
{{- else if eq $network "sepolia" -}}
11155111
{{- else if eq $network "hoodi" -}}
560048
{{- else -}}
{{- fail (printf "ERROR: Unknown network '%s'. Supported networks: mainnet, sepolia, hoodi" $network) -}}
{{- end -}}
{{- end -}}

{{/*
Get the network name
Returns the network value from .Values.network
*/}}
{{- define "dv-pod.network" -}}
{{- if not .Values.network -}}
{{- fail "ERROR: network parameter is required. Please set --set network=<mainnet|sepolia|hoodi>" -}}
{{- end -}}
{{- .Values.network -}}
{{- end -}}

{{/*
Get the chainId
Derives chainId from the network name
*/}}
{{- define "dv-pod.chainId" -}}
{{- include "dv-pod.chainIdFromNetwork" . -}}
{{- end -}}

{{/*
Selector labels for the central-monitoring Prometheus. Must not overlap dv-pod.selectorLabels,
which select the charon StatefulSet pods (Service, PDB, ServiceMonitor).
*/}}
{{- define "dv-pod.prometheusSelectorLabels" -}}
app.kubernetes.io/name: {{ include "dv-pod.name" . }}-prometheus
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{- define "dv-pod.prometheusLabels" -}}
helm.sh/chart: {{ include "dv-pod.chart" . }}
{{ include "dv-pod.prometheusSelectorLabels" . }}
app.kubernetes.io/component: prometheus
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Shell snippet: copy the ENR private key into /charon-data, where `charon dkg` requires it.
Refuses to continue if a different key is already there (identity mismatch).
*/}}
{{- define "dv-pod.stageEnrKey" -}}
ENR_SRC="/enr-from-job/{{ include "dv-pod.enrSecretDataKey" . }}"
ENR_DST="/charon-data/charon-enr-private-key"
if [ -f "$ENR_DST" ]; then
  if [ "$(cat "$ENR_DST")" != "$(cat "$ENR_SRC")" ]; then
    echo "ERROR: $ENR_DST differs from the ENR private key in Secret {{ include "dv-pod.enrSecretName" . }}."
    echo "This node would join the DKG with the wrong identity. Resolve manually; nothing was changed."
    exit 1
  fi
else
  cp "$ENR_SRC" "$ENR_DST" && chmod 600 "$ENR_DST"
fi
{{- end -}}
