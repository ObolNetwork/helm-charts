{{/*
Expand the name of the chart.
*/}}
{{- define "remote-signer.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
*/}}
{{- define "remote-signer.fullname" -}}
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
{{- define "remote-signer.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "remote-signer.labels" -}}
helm.sh/chart: {{ include "remote-signer.chart" . }}
{{ include "remote-signer.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "remote-signer.selectorLabels" -}}
app.kubernetes.io/name: {{ include "remote-signer.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Create the name of the service account to use
*/}}
{{- define "remote-signer.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- default (include "remote-signer.fullname" .) .Values.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}

{{/*
Image helper
*/}}
{{- define "remote-signer.image" -}}
{{- $tag := .Values.image.tag | default .Chart.AppVersion }}
{{- printf "%s:%s" .Values.image.repository $tag }}
{{- end }}

{{/*
Secret name for keystore password
*/}}
{{- define "remote-signer.keystorePasswordSecretName" -}}
{{- if .Values.keystorePassword.existingSecret }}
{{- .Values.keystorePassword.existingSecret }}
{{- else }}
{{- printf "%s-keystore-password" (include "remote-signer.fullname" .) }}
{{- end }}
{{- end }}

{{/*
PVC name
*/}}
{{- define "remote-signer.pvcName" -}}
{{- if .Values.persistence.existingClaim }}
{{- .Values.persistence.existingClaim }}
{{- else }}
{{- printf "%s-keystores" (include "remote-signer.fullname" .) }}
{{- end }}
{{- end }}
