{{/*
Render probe
*/}}
{{- define "vm.probe" -}}
{{- $probe := dig .type (default dict) .app.probe -}}
{{- tpl (toYaml $probe) . -}}
{{- end -}}

{{/*
HTTP GET probe path
*/}}
{{- define "vm.probe.http.path" -}}
{{- index .app.extraArgs "http.pathPrefix" | default "" | trimSuffix "/" -}}/health
{{- end -}}

{{/*
HTTP GET probe scheme
*/}}
{{- define "vm.probe.http.scheme" -}}
{{ ternary "HTTPS" "HTTP" (.app.extraArgs.tls | default false) }}
{{- end -}}

{{/*
Net probe port
*/}}
{{- define "vm.probe.port" -}}
{{ dig "ports" "name" "http" (.app | dict) }}
{{- end -}}
