{{- define "vm.namespace" -}}
  {{- $Release := (.helm).Release | default .Release -}}
  {{- $Values := (.helm).Values | default .Values -}}
  {{- $Capabilities := (.helm).Capabilities | default .Capabilities -}}
  {{- if semverCompare "<3.14.0" $Capabilities.HelmVersion.Version }}
    {{- fail "This chart requires helm version 3.14.0 or higher" }}
  {{- end }}
  {{- $Values.namespaceOverride | default ($Values.global).namespaceOverride | default $Release.Namespace -}}
{{- end -}}

{{- define "vm.validate.args" -}}
  {{- $Chart := (.helm).Chart | default .Chart -}}
  {{- if empty $Chart -}}
    {{- fail "invalid template data" -}}
  {{- end -}}
{{- end -}}

{{- /* Expand the name of the chart. */ -}}
{{- define "vm.name" -}}
  {{- include "vm.validate.args" . -}}
  {{- $Chart := (.helm).Chart | default .Chart -}}
  {{- $Values := (.helm).Values | default .Values -}}
  {{- $Values.nameOverride | default ($Values.global).nameOverride | default $Chart.Name | trunc 63 | trimSuffix "-" }}
{{- end -}}

{{- /*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/ -}}
{{- define "vm.fullname" -}}
  {{- include "vm.validate.args" . -}}
  {{- $Values := (.helm).Values | default .Values -}}
  {{- $Chart := (.helm).Chart | default .Chart -}}
  {{- $Release := (.helm).Release | default .Release -}}
  {{- $fullname := "" -}}
  {{- if .appKey -}}
    {{- $appKey := ternary (list .appKey) .appKey (kindIs "string" .appKey) -}}
    {{- $values := $Values -}}
    {{- $global := (index $Values.global $Chart.Name) | default dict -}}
    {{- range $ak := $appKey }}
      {{- if $values -}}
        {{- $values = (index $values $ak) | default dict -}}
      {{- end -}}
      {{- if $global -}}
        {{- $global = (index $global $ak) | default dict -}}
      {{- end -}}
      {{- if and (kindIs "map" $values) $values.name -}}
        {{- $fullname = $values.name -}}
      {{- else if and (kindIs "map" $values) $values.fullnameOverride -}}
        {{- $fullname = $values.fullnameOverride -}}
      {{- else if and (kindIs "map" $global) $global.name -}}
        {{- $fullname = $global.name -}}
      {{- end -}}
    {{- end }}
  {{- end -}}
  {{- if empty $fullname -}}
    {{- if $Values.fullnameOverride -}}
      {{- $fullname = $Values.fullnameOverride -}}
    {{- else if (dig $Chart.Name "fullnameOverride" "" ($Values.global)) -}}
      {{- $fullname = (dig $Chart.Name "fullnameOverride" "" ($Values.global)) -}}
    {{- else if ($Values.global).fullnameOverride -}}
      {{- $fullname = $Values.global.fullnameOverride -}}
    {{- else -}}
      {{- $name := default $Chart.Name $Values.nameOverride -}}
      {{- if contains $name $Release.Name -}}
        {{- $fullname = $Release.Name -}}
      {{- else -}}
        {{- $fullname = (printf "%s-%s" $Release.Name $name) }}
      {{- end -}}
    {{- end -}}
  {{- end -}}
  {{- with .prefix -}}
    {{- $fullname = printf "%s-%s" . $fullname -}}
  {{- end -}}
  {{- with .suffix -}}
    {{- $fullname = printf "%s-%s" $fullname . -}}
  {{- end -}}
  {{- $fullname | trunc 63 | trimSuffix "-" -}}
{{- end }}

{{- define "vm.managed.fullname" -}}
  {{- $prefix := .appKey -}}
  {{- $oldPrefix := .prefix -}}
  {{- if kindIs "slice" $prefix -}}
    {{- $prefix = last $prefix -}}
  {{- end -}}
  {{- if $prefix -}}
    {{- with $oldPrefix -}}
      {{- $prefix = printf "%s-%s" $prefix . -}}
    {{- end }}
    {{- $_ := set $ "prefix" $prefix -}}
  {{- end -}}
  {{- include "vm.fullname" . -}}
  {{- $_ := set . "prefix" $oldPrefix -}}
{{- end -}}

{{- define "vm.plain.fullname" -}}
  {{- $suffix := .appKey -}}
  {{- $oldSuffix := .suffix -}}
  {{- if kindIs "slice" $suffix -}}
    {{- $suffix = last $suffix }}
  {{- end -}}
  {{- if $suffix -}}
    {{- with $oldSuffix -}}
      {{- $suffix = printf "%s-%s" $suffix . -}}
    {{- end -}}
    {{- $_ := set . "suffix" $suffix -}}
  {{- end -}}
  {{- include "vm.fullname" . -}}
  {{- $_ := set . "suffix" $oldSuffix -}}
{{- end -}}

{{- /* Create chart name and version as used by the chart label. */ -}}
{{- define "vm.chart" -}}
  {{- include "vm.validate.args" . -}}
  {{- $Chart := (.helm).Chart | default .Chart -}}
  {{- printf "%s-%s" $Chart.Name $Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{- /* Create the name of the service account to use */ -}}
{{- define "vm.sa.name" -}}
  {{- include "vm.validate.args" . -}}
  {{- $Values := (.helm).Values | default .Values -}}
  {{- if $Values.serviceAccount.create }}
    {{- default (include "vm.fullname" .) $Values.serviceAccount.name }}
  {{- else -}}
    {{- default "default" $Values.serviceAccount.name -}}
  {{- end }}
{{- end }}

{{- define "vm.metaLabels" -}}
  {{- include "vm.validate.args" . -}}
  {{- $Release := (.helm).Release | default .Release -}}
  {{- $labels := .extraLabels | default dict -}}
  {{- $_ := set $labels "helm.sh/chart" (include "vm.chart" .) -}}
  {{- $_ := set $labels "app.kubernetes.io/managed-by" $Release.Service -}}
  {{- toYaml $labels -}}
{{- end -}}

{{- /* Common labels */ -}}
{{- define "vm.labels" -}}
  {{- include "vm.validate.args" . -}}
  {{- $Chart := (.helm).Chart | default .Chart -}}
  {{- $labels := fromYaml (include "vm.selectorLabels" .) -}}
  {{- $labels = mergeOverwrite $labels (fromYaml (include "vm.metaLabels" .)) -}}
  {{- with $Chart.AppVersion -}}
    {{- $_ := set $labels "app.kubernetes.io/version" ($Chart.AppVersion) -}}
  {{- end -}}
  {{- toYaml $labels -}}
{{- end -}}

{{- define "vm.release" -}}
  {{- include "vm.validate.args" . -}}
  {{- $Release := (.helm).Release | default .Release -}}
  {{- $Values := (.helm).Values | default .Values -}}
  {{- default $Release.Name $Values.argocdReleaseOverride | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{- define "vm.app.name" -}}
  {{- if .appKey -}}
    {{- $Values := (.helm).Values | default .Values -}}
    {{- $Chart := (.helm).Chart | default .Chart -}}
    {{- $values := $Values -}}
    {{- $global := (index $Values.global $Chart.Name) | default dict -}}
    {{- $appKey := ternary (list .appKey) .appKey (kindIs "string" .appKey) -}}
    {{- $name := last $appKey }}
    {{- range $ak := $appKey }}
      {{- $values = (index $values $ak) | default dict -}}
      {{- $global = (index $global $ak) | default dict -}}
      {{- if $values.name -}}
        {{- $name = $values.name -}}
      {{- else if $global.name -}}
        {{- $name = $global.name -}}
      {{- end -}}
    {{- end -}}
    {{- $name -}}
  {{- end -}}
{{- end -}}

{{- /* Selector labels */ -}}
{{- define "vm.selectorLabels" -}}
  {{- $labels := .extraLabels | default dict -}}
  {{- $_ := set $labels "app.kubernetes.io/name" (include "vm.name" .) -}}
  {{- $_ := set $labels "app.kubernetes.io/instance" (include "vm.release" .) -}}
  {{- with (include "vm.app.name" .) -}}
    {{- $_ := set $labels "app" . -}}
  {{- end -}}
  {{- toYaml $labels -}}
{{- end }}
