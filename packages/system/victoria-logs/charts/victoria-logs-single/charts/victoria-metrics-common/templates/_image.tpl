{{/*
Victoria Metrics Image
*/}}
{{- define "vm.image" -}}
{{- $image := (printf "%s:%s" .app.image.repository (.app.image.tag | default .Chart.AppVersion)) -}}
{{- $license := .Values.license | default dict }}
{{- if and (or $license.key .Values.eula (dig "secret" "name" "" $license)) (empty .app.image.tag) -}}
  {{- $_ := set .app.image "variant" "enterprise" -}}
{{- end -}}
{{- with .app.image.variant -}}
  {{- $image = (printf "%s-%s" $image .) -}}
{{- end -}}
{{- with .app.image.registry | default .Values.global.image.registry -}}
  {{- $image = (printf "%s/%s" . $image) -}}
{{- end -}}
{{- $image -}}
{{- end -}}
