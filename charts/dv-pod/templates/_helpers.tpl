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
Determine the name of the shared ENR secret.
This secret holds the single ENR private key for the entire cluster.
Logic:
1. If .Values.charon.enr.privateKey is set, the ENR job creates a predictable secret.
2. Else if .Values.charon.enr.existingSecret.name is set, use that.
3. Else if .Values.charon.enr.generate.enabled is true, the ENR job creates a predictable secret.
4. Fallback to the predictable secret name (though hook conditions should prevent needing this directly for non-generation scenarios).
*/}}
{{- define "dv-pod.enrSecretName" -}}
{{- if or .Values.charon.enr.privateKey .Values.charon.enr.generate.enabled (not .Values.charon.enr.existingSecret.name) -}}
{{- printf "%s-enr-key" (include "dv-pod.fullname" .) -}}
{{- else if .Values.charon.enr.existingSecret.name -}}
{{- .Values.charon.enr.existingSecret.name -}}
{{- end -}}
{{- end -}}

{{/*
Return the data key for the ENR private key within the shared secret.
*/}}
{{- define "dv-pod.enrSecretDataKey" -}}
{{- .Values.charon.enr.existingSecret.dataKey | default "private-key" -}}
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
{{- end -}}
{{- end -}}
