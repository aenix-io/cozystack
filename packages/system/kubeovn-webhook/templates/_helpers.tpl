{{- define "namespace-annotation-webhook.name" -}}
kube-ovn-webhook
{{- end }}

{{- define "namespace-annotation-webhook.fullname" -}}
{{- if .Release.Name | eq .Chart.Name }}
{{- printf "%s" .Release.Name | trunc 63 | trimSuffix "-" -}}
{{- else }}
{{- printf "%s-%s" .Release.Name (include "namespace-annotation-webhook.name" . ) | trunc 63 | trimSuffix "-" -}}
{{- end }}
{{- end }}
