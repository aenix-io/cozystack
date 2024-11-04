{{/* vim: set filetype=mustache: */}}
{{/*
Expand the name of the chart.
*/}}
{{- define "vm-operator.name" -}}
{{- $Chart :=(.helm).Chart | default .Chart -}}
{{- $Values :=(.helm).Values | default .Values -}}
{{- default $Chart.Name $Values.nameOverride | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{- define "vm-operator.cleanup.annotations" -}}
"helm.sh/hook": pre-delete
"helm.sh/hook-weight": "{{ .hookWeight }}"
"helm.sh/hook-delete-policy": before-hook-creation
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "vm-operator.fullname" -}}
  {{- $Values :=(.helm).Values | default .Values -}}
  {{- $Release :=(.helm).Release | default .Release -}}
  {{- $Chart := (.helm).Chart | default .Chart -}}
  {{- if $Values.fullnameOverride -}}
    {{- $Values.fullnameOverride | trunc 63 | trimSuffix "-" -}}
  {{- else -}}
    {{- $name := default $Chart.Name $Values.nameOverride -}}
    {{- if contains $name $Release.Name -}}
      {{- $Release.Name | trunc 63 | trimSuffix "-" -}}
    {{- else -}}
      {{- printf "%s-%s" $Release.Name $name | trunc 63 | trimSuffix "-" -}}
    {{- end -}}
  {{- end -}}
{{- end -}}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "vm-operator.chart" -}}
  {{- $Chart := (.helm).Chart | default .Chart -}}
  {{- printf "%s-%s" $Chart.Name $Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Create the name of the service account
*/}}
{{- define "vm-operator.serviceAccountName" -}}
  {{- $Values := (.helm).Values | default .Values }}
  {{- if $Values.serviceAccount.create -}}
    {{ default (include "vm-operator.fullname" .) $Values.serviceAccount.name }}
  {{- else -}}
    {{ default "default" $Values.serviceAccount.name }}
  {{- end -}}
{{- end -}}

{{/*
Selector labels
*/}}
{{- define "vm-operator.selectorLabels" -}}
{{- $Release := (.helm).Release | default .Release -}}
app.kubernetes.io/name: {{ include "vm-operator.name" . }}
app.kubernetes.io/instance: {{ $Release.Name | trunc 63 | trimSuffix "-" }}
{{- with .extraLabels }}
{{ toYaml . }}
{{- end }}
{{- end -}}

{{/*
Create unified labels for vm-operator components
*/}}
{{- define "vm-operator.labels" -}}
{{- include "vm-operator.selectorLabels" . }}
{{- $Release := (.helm).Release | default .Release }}
helm.sh/chart: {{ include "vm-operator.chart" . }}
app.kubernetes.io/managed-by: {{ $Release.Service | trunc 63 | trimSuffix "-" }}
{{- end -}}

{{/*
Create unified annotations for vm-operator components
*/}}
{{- define "vm-operator.crds.annotations" -}}
{{- $Release :=(.helm).Release | default .Release -}}
helm.sh/resource-policy: keep
meta.helm.sh/release-namespace: {{ include "vm.namespace" . }}
meta.helm.sh/release-name: {{ $Release.Name }}
{{- end -}}

{{/*
Create the name of service account and clusterRole for cleanup-hook
*/}}
{{- define "vm-operator.cleanupHookName" -}}
  {{- include "vm-operator.fullname" . }}-cleanup-hook
{{- end }}

{{/*
Generate certificates for webhook
*/}}
{{- define "vm-operator.certs" -}}
{{- $Values := (.helm).Values | default .Values }}
{{- $Release := (.helm).Release | default .Release }}
{{- $webhook := $Values.admissionWebhooks -}}
{{- $tls := $webhook.tls -}}
{{- $serviceName := (include "vm-operator.fullname" .) -}}
{{- $secretName := (printf "%s-validation" $serviceName) -}}
{{- $secret := lookup "v1" "Secret" (include "vm.namespace" .) $secretName -}}
{{- if (and $tls.caCert $tls.cert $tls.key) -}}
caCert: {{ $tls.caCert | b64enc }}
clientCert: {{ $tls.cert | b64enc }}
clientKey: {{ $tls.key | b64enc }}
{{- else if and $webhook.keepTLSSecret $secret -}}
caCert: {{ index $secret.data "ca.crt" }}
clientCert: {{ index $secret.data "tls.crt" }}
clientKey: {{ index $secret.data "tls.key" }}
{{- else -}}
{{- $altNames := default list -}}
{{- $namePrefix := (printf "%s.%s" $serviceName (include "vm.namespace" .)) -}}
{{- $altNames = append $altNames $namePrefix -}}
{{- $altNames = append $altNames (printf "%s.svc" $namePrefix) -}}
{{- $altNames = append $altNames (printf "%s.svc.%s" $namePrefix $Values.global.cluster.dnsDomain) -}}
{{- $ca := genCA "vm-operator-ca" 3650 -}}
{{- $cert := genSignedCert $serviceName nil $altNames 3650 $ca -}}
caCert: {{ $ca.Cert | b64enc }}
clientCert: {{ $cert.Cert | b64enc }}
clientKey: {{ $cert.Key | b64enc }}
{{- end -}}
{{- end -}}
