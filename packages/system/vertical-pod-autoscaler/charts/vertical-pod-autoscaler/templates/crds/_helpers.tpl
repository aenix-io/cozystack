{{/* vim: set filetype=mustache: */}}
{{/*
Create a default fully qualified app name.
*/}}
{{- define "vertical-pod-autoscaler.crds.fullname" -}}
{{- printf "%s-%s" (include "vertical-pod-autoscaler.fullname" .) "crds" | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Component labels
*/}}
{{- define "vertical-pod-autoscaler.crds.componentLabels" -}}
app.kubernetes.io/component: crds
{{- end -}}

{{/*
Common labels
*/}}
{{- define "vertical-pod-autoscaler.crds.labels" -}}
{{ include "vertical-pod-autoscaler.labels" . }}
{{ include "vertical-pod-autoscaler.crds.componentLabels" . }}
{{- end -}}

{{/*
Selector labels
*/}}
{{- define "vertical-pod-autoscaler.crds.selectorLabels" -}}
{{ include "vertical-pod-autoscaler.selectorLabels" . }}
{{ include "vertical-pod-autoscaler.crds.componentLabels" . }}
{{- end -}}
