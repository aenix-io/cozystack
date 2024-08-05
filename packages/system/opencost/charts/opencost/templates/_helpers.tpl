{{/* vim: set filetype=mustache: */}}
{{/*
Expand the name of the chart.
*/}}
{{- define "opencost.name" -}}
  {{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "opencost.chart" -}}
  {{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
*/}}
{{- define "opencost.fullname" -}}
  {{- if .Values.fullnameOverride -}}
    {{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" -}}
  {{- else -}}
    {{- $name := default .Chart.Name .Values.nameOverride -}}
    {{- if contains $name .Release.Name -}}
      {{- .Release.Name | trunc 63 | trimSuffix "-" -}}
    {{- else -}}
      {{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" -}}
    {{- end -}}
  {{- end -}}
{{- end -}}

{{/*
Allow the release namespace to be overridden
*/}}
{{- define "opencost.namespace" -}}
  {{- if .Values.namespaceOverride -}}
    {{- .Values.namespaceOverride -}}
  {{- else -}}
    {{- .Release.Namespace -}}
  {{- end -}}
{{- end -}}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
*/}}
{{- define "opencost.prometheus.secretname" -}}
  {{- if .Values.opencost.prometheus.secret_name -}}
    {{- .Values.opencost.prometheus.secret_name -}}
  {{- else -}}
    {{- include "opencost.fullname" . -}}
  {{- end -}}
{{- end -}}

{{/*
Common labels
*/}}
{{- define "opencost.labels" -}}
helm.sh/chart: {{ include "opencost.chart" . }}
{{ include "opencost.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/part-of: {{ template "opencost.name" . }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- if .Values.commonLabels}}
{{ toYaml .Values.commonLabels }}
{{- end }}
{{- end -}}

{{/*
Selector labels
*/}}
{{- define "opencost.selectorLabels" -}}
app.kubernetes.io/name: {{ include "opencost.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end -}}

{{/*
Create the name of the controller service account to use
*/}}
{{- define "opencost.serviceAccountName" -}}
  {{- if .Values.serviceAccount.create -}}
    {{- default (include "opencost.fullname" .) .Values.serviceAccount.name }}
  {{- else -}}
    {{- default "default" .Values.serviceAccount.name }}
  {{- end -}}
{{- end -}}

{{/*
Create the name of the controller service account to use
*/}}
{{- define "opencost.prometheusServerEndpoint" -}}
  {{- if .Values.opencost.prometheus.external.enabled -}}
    {{ tpl .Values.opencost.prometheus.external.url . }}
  {{- else if (and .Values.opencost.prometheus.amp.enabled .Values.opencost.sigV4Proxy) -}}
    {{- $port := .Values.opencost.sigV4Proxy.port | int }}
    {{- $ws := .Values.opencost.prometheus.amp.workspaceId }}
    {{- printf "http://localhost:%d/workspaces/%v" $port $ws -}}
  {{- else -}}
    {{- $host := tpl .Values.opencost.prometheus.internal.serviceName . }}
    {{- $ns := tpl .Values.opencost.prometheus.internal.namespaceName . }}
    {{- $port := .Values.opencost.prometheus.internal.port | int }}
    {{- printf "http://%s.%s.svc.cluster.local:%d" $host $ns $port -}}
  {{- end -}}
{{- end -}}

{{/*
Check that either thanos external or internal is defined
*/}}
{{- define "opencost.thanosServerEndpoint" -}}
  {{- if .Values.opencost.prometheus.thanos.external.enabled -}}
    {{ .Values.opencost.prometheus.thanos.external.url }}
  {{- else -}}
    {{- $host := .Values.opencost.prometheus.thanos.internal.serviceName }}
    {{- $ns := .Values.opencost.prometheus.thanos.internal.namespaceName }}
    {{- $port := .Values.opencost.prometheus.thanos.internal.port | int }}
    {{- printf "http://%s.%s.svc.cluster.local:%d" $host $ns $port -}}
  {{- end -}}
{{- end -}}

{{/*
Check that the config is valid
*/}}
{{- define "isPrometheusConfigValid" -}}
  {{- $prometheusModes := add .Values.opencost.prometheus.external.enabled .Values.opencost.prometheus.internal.enabled .Values.opencost.prometheus.amp.enabled | int }}
  {{- if gt $prometheusModes 1 -}}
    {{- fail "Only use one of the prometheus setups: internal, external, or amp" -}}
  {{- end -}}
  {{- if .Values.opencost.prometheus.thanos.enabled -}}
    {{- if and .Values.opencost.prometheus.thanos.external.enabled .Values.opencost.prometheus.thanos.internal.enabled -}}
      {{- fail "Only use one of the thanos setups: internal or external" -}}
    {{- end -}}
  {{- end -}}
{{- end -}}

{{/*
Define opencost config file name
*/}}
{{- define "opencost.configFileName" -}}
  {{- if  eq .Values.opencost.customPricing.provider "custom" -}}
    {{- print "default" -}}
  {{- else -}}
    {{- .Values.opencost.customPricing.provider -}}
  {{- end -}}
{{- end -}}

{{/*
Get api version of networking.k8s.io
*/}}
{{- define "networkingAPIVersion" -}}
{{- if .Capabilities.APIVersions.Has "networking.k8s.io/v1" }}
apiVersion: networking.k8s.io/v1
{{- else if .Capabilities.APIVersions.Has "networking.k8s.io/v1beta1" }}
apiVersion: networking.k8s.io/v1beta1
{{- end }}
{{- end -}}

{{- define "opencost.imageTag" -}}
{{ .Values.opencost.exporter.image.tag | default (printf "%s" .Chart.AppVersion) }}
{{- end -}}

{{- define "opencost.fullImageName" -}}
{{- if .Values.opencost.exporter.image.fullImageName }}
{{- .Values.opencost.exporter.image.fullImageName -}}
{{- else}}
{{- .Values.opencost.exporter.image.registry -}}/{{- .Values.opencost.exporter.image.repository -}}:{{- include "opencost.imageTag" . -}}
{{- end -}}
{{- end -}}

{{- define "opencostUi.imageTag" -}}
{{- .Values.opencost.ui.image.tag | default (printf "%s" .Chart.AppVersion) -}}
{{- end -}}

{{- define "opencostUi.fullImageName" -}}
{{- if .Values.opencost.ui.image.fullImageName }}
{{- .Values.opencost.ui.image.fullImageName -}}
{{- else}}
{{- .Values.opencost.ui.image.registry -}}/{{- .Values.opencost.ui.image.repository -}}:{{- include "opencostUi.imageTag" . -}}
{{- end -}}
{{- end -}}