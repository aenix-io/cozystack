{{/*
Return the proper dashboard image name
*/}}
{{- define "kubeapps.dashboard.image" -}}
{{ .Files.Get "images/dashboard.tag" | trim }}@{{ index (.Files.Get "images/dashboard.json" | fromJson) "containerimage.digest" }}
{{- end -}}

{{/*
Return the proper kubeappsapis image name
*/}}
{{- define "kubeapps.kubeappsapis.image" -}}
{{ .Files.Get "images/kubeapps-apis.tag" | trim }}@{{ index (.Files.Get "images/kubeapps-apis.json" | fromJson) "containerimage.digest" }}
{{- end -}}
