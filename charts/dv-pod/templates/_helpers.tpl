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
1. If .Values.charon.enr.existingSecret.name is set, use that (explicit override).
2. Else if .Values.secrets.defaultEnrPrivateKey is set, use that as the default.
3. Else if .Values.charon.enr.privateKey is set or .Values.charon.enr.generate.enabled is true, 
   the ENR job creates a predictable secret.
4. Fallback to the predictable secret name.
*/}}
{{- define "dv-pod.enrSecretName" -}}
{{- if .Values.charon.enr.existingSecret.name -}}
{{- .Values.charon.enr.existingSecret.name -}}
{{- else if .Values.secrets.defaultEnrPrivateKey -}}
{{- .Values.secrets.defaultEnrPrivateKey -}}
{{- else if or .Values.charon.enr.privateKey .Values.charon.enr.generate.enabled -}}
{{- printf "%s-enr-key" (include "dv-pod.fullname" .) -}}
{{- else -}}
{{- printf "%s-enr-key" (include "dv-pod.fullname" .) -}}
{{- end -}}
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
The job should be created if:
1. Generate is enabled AND
2. No private key is directly provided AND
3. ENR job is enabled
Note: The job will run even if an existing secret is specified, as it can handle incomplete secrets
(secrets with only private key missing the public ENR field)
*/}}
{{- define "dv-pod.shouldCreateEnrJob" -}}
{{- if and .Values.charon.enr.generate.enabled (not .Values.charon.enr.privateKey) .Values.charon.enrJob.enabled -}}
true
{{- end -}}
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

{{/*
Validate Ethereum address format
This function validates that an address:
1. Starts with "0x"
2. Is exactly 42 characters long (0x + 40 hex digits)
3. Contains only valid hexadecimal characters
Note: This does NOT validate EIP-55 checksum as Helm lacks Keccak-256 hashing.
Users should ensure they use properly checksummed addresses.
*/}}
{{- define "dv-pod.validateEthereumAddress" -}}
{{- $address := . -}}
{{- if not (hasPrefix "0x" $address) -}}
{{- fail (printf "Invalid Ethereum address '%s': must start with '0x'" $address) -}}
{{- end -}}
{{- if ne (len $address) 42 -}}
{{- fail (printf "Invalid Ethereum address '%s': must be exactly 42 characters (0x + 40 hex digits), got %d characters" $address (len $address)) -}}
{{- end -}}
{{- if not (regexMatch "^0x[0-9a-fA-F]{40}$" $address) -}}
{{- fail (printf "Invalid Ethereum address '%s': must contain only hexadecimal characters (0-9, a-f, A-F) after '0x' prefix" $address) -}}
{{- end -}}
{{- end -}}

{{/*
Convert network name to chainId
Supported networks:
- mainnet: 1
- sepolia: 11155111
- hoodi: 560048
- gnosis: 100
*/}}
{{- define "dv-pod.chainId" -}}
{{- $network := .Values.network -}}
{{- if eq $network "mainnet" -}}
1
{{- else if eq $network "sepolia" -}}
11155111
{{- else if eq $network "hoodi" -}}
560048
{{- else if eq $network "gnosis" -}}
100
{{- else -}}
{{- fail (printf "Unknown network: '%s'. Supported networks are: mainnet, sepolia, hoodi, gnosis" $network) -}}
{{- end -}}
{{- end -}}

{{/*
Get the network name for validator client configuration
If validatorClient.config.network is explicitly set, use that value.
Otherwise, auto-derive from the top-level network setting.
*/}}
{{- define "dv-pod.validatorNetwork" -}}
{{- if .Values.validatorClient.config.network -}}
{{- .Values.validatorClient.config.network -}}
{{- else if .Values.network -}}
{{- .Values.network -}}
{{- end -}}
{{- end -}}
