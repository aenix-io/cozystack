{{- define "tenant.name" -}}
{{- if ne (len (splitList "-" .Release.Name)) 1 }}
{{- fail (printf "Release name should not contain dashes: %s" .Release.Name) }}
{{- end }}
{{- printf "tenant-%s" .Release.Name }}
{{- if and (ne .Release.Namespace "tenant-root") (hasPrefix "tenant-" .Release.Namespace) }}
{{- printf "%s-%s" .Release.Namespace .Release.Name }}
{{- end }}
{{- end }}
