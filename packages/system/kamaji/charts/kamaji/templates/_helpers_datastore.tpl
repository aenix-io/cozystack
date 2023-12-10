{{/*
Create a default fully qualified datastore name.
*/}}
{{- define "datastore.fullname" -}}
{{- if .Values.datastore.enabled }}
{{- default "default" .Values.datastore.nameOverride | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- required "A valid .Values.datastore.nameOverride required!" .Values.datastore.nameOverride }}
{{- end }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "datastore.labels" -}}
kamaji.clastix.io/datastore: {{ .Values.datastore.driver }}
helm.sh/chart: {{ include "kamaji.chart" . }}
{{ include "kamaji.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Datastore endpoints, in case of ETCD, retrieving the one provided by the chart.
*/}}
{{- define "datastore.endpoints" -}}
{{- if eq .Values.datastore.driver "etcd" }}
{{ include "etcd.endpoints" . }}
{{- else }}
{{ .Values.datastore.endpoints }}
{{- end }}
{{- end }}

{{/*
The Certificate Authority section for the DataSource object.
*/}}
{{- define "datastore.certificateAuthority" -}}
{{- if eq .Values.datastore.driver "etcd" }}
certificate:
  secretReference:
    name: {{ include "etcd.caSecretName" . }}
    namespace: {{ include "etcd.caSecretNamespace" . }}
    keyPath: ca.crt
privateKey:
  secretReference:
    name: {{ include "etcd.caSecretName" . }}
    namespace: {{ include "etcd.caSecretNamespace" . }}
    keyPath: ca.key
{{- else }}
certificate:
  secretReference:
    name: {{ .Values.datastore.tlsConfig.certificateAuthority.certificate.name }}
    namespace: {{ .Values.datastore.tlsConfig.certificateAuthority.certificate.namespace }}
    keyPath: {{ .Values.datastore.tlsConfig.certificateAuthority.certificate.keyPath }}
{{- if .Values.datastore.tlsConfig.certificateAuthority.privateKey.name }}
privateKey:
  secretReference:
    name: {{ .Values.datastore.tlsConfig.certificateAuthority.privateKey.name }}
    namespace: {{ .Values.datastore.tlsConfig.certificateAuthority.privateKey.namespace }}
    keyPath: {{ .Values.datastore.tlsConfig.certificateAuthority.privateKey.keyPath }}
{{- end }}
{{- end }}
{{- end }}

{{/*
The Client Certificate section for the DataSource object.
*/}}
{{- define "datastore.clientCertificate" -}}
{{- if eq .Values.datastore.driver "etcd" }}
certificate:
    secretReference:
      name: {{ include "etcd.clientSecretName" . }}
      namespace: {{ include "etcd.clientSecretNamespace" . }}
      keyPath: tls.crt
privateKey:
    secretReference:
      name: {{ include "etcd.clientSecretName" . }}
      namespace: {{ include "etcd.clientSecretNamespace" . }}
      keyPath: tls.key
{{- else }}
certificate:
  secretReference:
    name: {{ .Values.datastore.tlsConfig.clientCertificate.certificate.name }}
    namespace: {{ .Values.datastore.tlsConfig.clientCertificate.certificate.namespace }}
    keyPath: {{ .Values.datastore.tlsConfig.clientCertificate.certificate.keyPath }}
privateKey:
  secretReference:
    name: {{ .Values.datastore.tlsConfig.clientCertificate.privateKey.name }}
    namespace: {{ .Values.datastore.tlsConfig.clientCertificate.privateKey.namespace }}
    keyPath: {{ .Values.datastore.tlsConfig.clientCertificate.privateKey.keyPath }}
{{- end }}
{{- end }}
