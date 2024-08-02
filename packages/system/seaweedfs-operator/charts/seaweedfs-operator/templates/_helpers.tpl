{{/*
Expand the name of the chart.
*/}}
{{- define "seaweedfs-operator.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "seaweedfs-operator.fullname" -}}
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
{{- define "seaweedfs-operator.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "seaweedfs-operator.labels" -}}
helm.sh/chart: {{ include "seaweedfs-operator.chart" . }}
{{ include "seaweedfs-operator.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "seaweedfs-operator.selectorLabels" -}}
app.kubernetes.io/name: {{ include "seaweedfs-operator.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Docker registry image pull secret
*/}}
{{- define "seaweedfs-operator.imagePullSecret" }}
{{- $auth := printf "%s:%s" .username .password | b64enc -}}
{{- printf "{\"auths\": {\"%s\": {\"auth\": \"%s\"}}}" .registry $auth | b64enc }}
{{- end }}

{{- define "seaweedfs-operator.createPullSecret" -}}
{{- if and .Values.image.credentials (not .Values.image.pullSecrets) }}
  {{- true -}}
{{- else -}}
{{- end -}}
{{- end -}}

{{- define "seaweedfs-operator.pullSecretName" -}}
{{- if .Values.image.pullSecrets -}}
  {{- printf "%s" (tpl .Values.image.pullSecrets .) -}}
{{- else -}}
  {{- printf "%s-container-registry" (include "seaweedfs-operator.fullname" .) -}}
{{- end -}}
{{- end -}}
