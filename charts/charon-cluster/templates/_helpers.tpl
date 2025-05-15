{{/*
Expand the name of the chart.
*/}}
{{- define "charon.name" -}}
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
{{- define "charon.fullname" -}}
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
{{- define "charon.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "charon.labels" -}}
helm.sh/chart: {{ include "charon.chart" . }}
{{ include "charon.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "charon.selectorLabels" -}}
app.kubernetes.io/name: {{ include "charon.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Create the name of the service account to use
*/}}
{{- define "charon.serviceAccountName" -}}
{{- if and (.Values.serviceAccount.enabled) (.Values.serviceAccount.name) }}
{{- default .Values.serviceAccount.name }}
{{- else }}
{{- default .Release.Name }}
{{- end }}
{{- end }}

{{/*
Determine the name of the shared ENR secret.
This secret holds the single ENR private key for the entire cluster.
Logic:
1. If .Values.charon.enr.privateKey is set, the ENR job creates a predictable secret.
2. Else if .Values.charon.enr.existingSecret.name is set, use that.
3. Else if .Values.charon.enr.generate.enabled is true, the ENR job creates a predictable secret.
4. Fallback to the predictable secret name (though hook conditions should prevent needing this directly for non-generation scenarios).
*/}}
{{- define "charon.enrSecretName" -}}
{{- if or .Values.charon.enr.privateKey .Values.charon.enr.generate.enabled (not .Values.charon.enr.existingSecret.name) -}}
{{- printf "%s-enr-key" (include "charon.fullname" .) -}}
{{- else if .Values.charon.enr.existingSecret.name -}}
{{- .Values.charon.enr.existingSecret.name -}}
{{- end -}}
{{- end -}}

{{/*
Return the data key for the ENR private key within the shared secret.
*/}}
{{- define "charon.enrSecretDataKey" -}}
{{- .Values.charon.enr.existingSecret.dataKey | default "private-key" -}}
{{- end -}}
