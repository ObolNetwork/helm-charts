{{/*
Expand the name of the chart.
*/}}
{{- define "lido-charon-dv-node.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "lido-charon-dv-node.fullname" -}}
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
{{- define "lido-charon-dv-node.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "lido-charon-dv-node.labels" -}}
helm.sh/chart: {{ include "lido-charon-dv-node.chart" . }}
{{ include "lido-charon-dv-node.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "lido-charon-dv-node.selectorLabels" -}}
app.kubernetes.io/name: {{ include "lido-charon-dv-node.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Component specific selector labels
*/}}
{{- define "lido-charon-dv-node.componentSelectorLabels" -}}
app.kubernetes.io/name: {{ include "lido-charon-dv-node.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
app.kubernetes.io/component: {{ .component }}
{{- end }}

{{/*
Create the name of the service account to use
*/}}
{{- define "lido-charon-dv-node.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- default (include "lido-charon-dv-node.fullname" .) .Values.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}

{{/*
Create the JWT secret name
*/}}
{{- define "lido-charon-dv-node.jwtSecretName" -}}
{{- printf "%s-jwt" (include "lido-charon-dv-node.fullname" .) }}
{{- end }}

{{/*
Create the network name based on the global network setting
*/}}
{{- define "lido-charon-dv-node.network" -}}
{{- .Values.global.network | default "mainnet" }}
{{- end }}

{{/*
Get the Lido execution layer rewards address based on network
*/}}
{{- define "lido-charon-dv-node.lidoExecutionRewardsAddress" -}}
{{- if eq (include "lido-charon-dv-node.network" .) "mainnet" }}
{{- "0x388C818CA8B9251b393131C08a736A67ccB19297" }}
{{- else if eq (include "lido-charon-dv-node.network" .) "hoodi" }}
{{- "0x0000000000000000000000000000000000000000" }}
{{- else }}
{{- "0x0000000000000000000000000000000000000000" }}
{{- end }}
{{- end }}

{{/*
Get MEV-boost relays based on network
*/}}
{{- define "lido-charon-dv-node.mevBoostRelays" -}}
{{- if .Values.mevBoost.relays }}
{{- .Values.mevBoost.relays }}
{{- else if eq (include "lido-charon-dv-node.network" .) "mainnet" }}
{{- "https://0xac6e77dfe25ecd6110b8e780608cce0dab71fdd5ebea22a16c0205200f2f8e2e3ad3b71d3499c54ad14d6c21b41a37ae@boost-relay.flashbots.net,https://0x8b5d2e73e2a3a55c6c87b8b6eb92e0149a125c852751db1422fa951e42a09b82c142c3ea98d0d9930b056a3bc9896b8f@bloxroute.max-profit.blxrbdn.com,https://0xb0b07cd0abef743db4260b0ed50619cf6ad4d82064cb4fbec9d3ec530f7c5e6793d9f286c4e082c0244ffb9f2658fe88@bloxroute.regulated.blxrbdn.com" }}
{{- else if eq (include "lido-charon-dv-node.network" .) "hoodi" }}
{{- "" }}
{{- else }}
{{- "" }}
{{- end }}
{{- end }}

{{/*
Get checkpoint sync URL based on network
*/}}
{{- define "lido-charon-dv-node.checkpointSyncUrl" -}}
{{- if .Values.lighthouse.checkpointSyncUrl }}
{{- .Values.lighthouse.checkpointSyncUrl }}
{{- else if eq (include "lido-charon-dv-node.network" .) "mainnet" }}
{{- "https://mainnet.checkpoint.sigp.io" }}
{{- else if eq (include "lido-charon-dv-node.network" .) "hoodi" }}
{{- "" }}
{{- else }}
{{- "" }}
{{- end }}
{{- end }}