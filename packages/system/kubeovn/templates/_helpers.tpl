{{- define "kubeovn.image" -}}
{{ .Files.Get "images/kubeovn.tag" | trim }}@{{ index (.Files.Get "images/kubeovn.json" | fromJson) "containerimage.digest" }}
{{- end -}}
