{{/* vim: set filetype=mustache: */}}
{{/*
Expand the name of the chart.
*/}}
{{- define "victoria-logs.name" -}}
{{- default .Chart.Name .Values.global.nameOverride | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "victoria-logs.fullname" -}}
{{- if .Values.global.victoriaLogs.server.fullnameOverride -}}
{{- .Values.global.victoriaLogs.server.fullnameOverride | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- $name := default .Chart.Name .Values.global.nameOverride -}}
{{- if contains $name .Release.Name -}}
{{- .Release.Name | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" -}}
{{- end -}}
{{- end -}}
{{- end -}}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "victoria-logs.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Create the name of the service account
*/}}

{{/*
Create unified labels for victoria-logs components
*/}}
{{- define "victoria-logs.common.matchLabels" -}}
app.kubernetes.io/name: {{ include "victoria-logs.name" . }}
app.kubernetes.io/instance: {{ .Release.Name | trunc 63 | trimSuffix "-" }}
{{- end -}}

{{- define "victoria-logs.common.metaLabels" -}}
helm.sh/chart: {{ include "victoria-logs.chart" . }}
app.kubernetes.io/managed-by: {{ .Release.Service | trunc 63 | trimSuffix "-" }}
{{- with .extraLabels }}
{{ toYaml . }}
{{- end }}
{{- end -}}

{{- define "victoria-logs.server.labels" -}}
{{ include "victoria-logs.server.matchLabels" . }}
{{ include "victoria-logs.common.metaLabels" . }}
{{- end -}}

{{- define "victoria-logs.server.matchLabels" -}}
app: {{ .Values.global.victoriaLogs.server.name }}
{{ include "victoria-logs.common.matchLabels" . }}
{{- end -}}

{{/*
Create a fully qualified server name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).

Use hardcoded default value as this template will be used in Fluent Bit chart
and .Chart.Name will be "fluent-bit" in sub-chart context.
*/}}
{{- define "victoria-logs.server.fullname" -}}
{{- if .Values.global.victoriaLogs.server.fullnameOverride -}}
{{- .Values.global.victoriaLogs.server.fullnameOverride | trunc 63 | trimSuffix "-" -}}
{{- else -}}

{{- $name := default "victoria-logs-single" .Values.global.nameOverride -}}
{{- if contains $name .Release.Name -}}
{{- printf "%s-%s" .Release.Name .Values.global.victoriaLogs.server.name | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- printf "%s-%s-%s" .Release.Name $name .Values.global.victoriaLogs.server.name | trunc 63 | trimSuffix "-" -}}
{{- end -}}
{{- end -}}
{{- end -}}


{{- define "split-host-port" -}}
{{- $hp := split ":" . -}}
{{- printf "%s" $hp._1 -}}
{{- end -}}

{{- define "victoria-logs.hasInitContainer" -}}
    {{- (gt (len .Values.server.initContainers) 0) -}}
{{- end -}}

{{- define "victoria-logs.initContiners" -}}
{{- if eq (include "victoria-logs.hasInitContainer" . ) "true" -}}
{{- with .Values.server.initContainers -}}
{{ toYaml . }}
{{- end -}}
{{- else -}}
[]
{{- end -}}
{{- end -}}

{{/* 
Return true if the detected platform is Openshift
Usage:
{{- include "common.compatibility.isOpenshift" . -}}
*/}}
{{- define "common.compatibility.isOpenshift" -}}
{{- if .Capabilities.APIVersions.Has "security.openshift.io/v1" -}}
{{- true -}}
{{- end -}}
{{- end -}}

{{/*
Render a compatible securityContext depending on the platform. By default it is maintained as it is. In other platforms like Openshift we remove default user/group values that do not work out of the box with the restricted-v1 SCC
Usage:
{{- include "common.compatibility.renderSecurityContext" (dict "secContext" .Values.containerSecurityContext "context" $) -}}
*/}}
{{- define "common.compatibility.renderSecurityContext" -}}
{{- $adaptedContext := .secContext -}}
{{- if .context.Values.global.compatibility -}}
  {{- if .context.Values.global.compatibility.openshift -}}
    {{- if or (eq .context.Values.global.compatibility.openshift.adaptSecurityContext "force") (and (eq .context.Values.global.compatibility.openshift.adaptSecurityContext "auto") (include "common.compatibility.isOpenshift" .context)) -}}
      {{/* Remove incompatible user/group values that do not work in Openshift out of the box */}}
      {{- $adaptedContext = omit $adaptedContext "fsGroup" "runAsUser" "runAsGroup" -}}
      {{- if not .secContext.seLinuxOptions -}}
      {{/* If it is an empty object, we remove it from the resulting context because it causes validation issues */}}
      {{- $adaptedContext = omit $adaptedContext "seLinuxOptions" -}}
      {{- end -}}
    {{- end -}}
  {{- end -}}
{{- end -}}
{{- omit $adaptedContext "enabled" | toYaml -}}
{{- end -}}
