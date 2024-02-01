{{- define "tenant.name" -}}
{{- $parts := splitList "-" .Release.Name }}
{{- if or (ne ($parts|first) "tenant") (ne (len $parts) 2) }}
{{- fail (printf "The release name should start with \"tenant-\" and should not contain any other dashes: %s" .Release.Name) }}
{{- end }}
{{- if not (hasPrefix "tenant-" .Release.Namespace) }}
{{- fail (printf "The release namespace should start with \"tenant-\": %s" .Release.Namespace) }}
{{- end }}
{{- $tenantName := ($parts|last) }}
{{- if ne .Release.Namespace "tenant-root" }}
{{- printf "%s-%s" .Release.Namespace $tenantName }}
{{- else }}
{{- printf "tenant-%s" $tenantName }}
{{- end }}
{{- end }}
