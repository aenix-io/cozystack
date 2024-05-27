{{- define "cilium.image" -}}
{{ .Files.Get "images/cilium.tag" | trim }}@{{ index (.Files.Get "images/cilium.json" | fromJson) "containerimage.digest" }}
{{- end -}}
