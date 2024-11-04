{{/*
Victoria Metrics Image
*/}}
{{- define "vm.image" -}}
  {{- $Chart := (.helm).Chart | default .Chart -}}
  {{- $Values := (.helm).Values | default .Values -}}
  {{- $tag := .app.image.tag -}}
  {{- if empty $tag }}
    {{- $tag = $Chart.AppVersion -}}
    {{- $variant := .app.image.variant }}
    {{- if eq (include "vm.enterprise.disabled" .) "false" -}}
      {{- if $variant }}
        {{- $variant = printf "enterprise-%s" $variant }}
      {{- else }}
        {{- $variant = "enterprise" }}
      {{- end }}
    {{- end -}}
    {{- with $variant -}}
      {{- $tag = (printf "%s-%s" $tag .) -}}
    {{- end -}}
  {{- end -}}
  {{- $image := tpl (printf "%s:%s" .app.image.repository $tag) . -}}
  {{- with .app.image.registry | default (($Values.global).image).registry | default "" -}}
    {{- $image = (printf "%s/%s" . $image) -}}
  {{- end -}}
  {{- $image -}}
{{- end -}}
