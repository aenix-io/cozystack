{{- define "snippet.grafana.url" -}}
{{ .Values.url }}
{{- end }}

{{- define "snippet.redis.host" -}}
rfrm-{{ .Release.Name }}-grafana-oncall
{{- end }}

{{- define "snippet.redis.password.secret.name" -}}
{{ .Release.Name }}-grafana-oncall-redis-password
{{- end }}

{{- define "snippet.redis.password.secret.key" -}}
password
{{- end }}

{{- define "snippet.postgresql.host" -}}
{{ .Release.Name }}-grafana-oncall-db-rw
{{- end }}

{{- define "snippet.postgresql.password.secret.name" -}}
{{ .Release.Name }}-grafana-oncall-db-app
{{- end }}

{{- define "snippet.postgresql.user" -}}
app
{{- end }}

{{- define "snippet.postgresql.db" -}}
app
{{- end }}

{{- define "snippet.postgresql.password.secret.key" -}}
password
{{- end }}
