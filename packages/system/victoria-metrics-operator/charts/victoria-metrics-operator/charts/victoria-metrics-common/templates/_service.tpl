{{- /* Create the name for VM service */ -}}
{{- define "vm.service" -}}
  {{- include "vm.validate.args" . -}}
  {{- $Values := (.helm).Values | default .Values -}}
  {{- $nameTpl := "vm.fullname" }}
  {{- if eq .style "managed" -}}
    {{- $nameTpl = "vm.managed.fullname" }}
  {{- else if eq .style "plain" -}}
    {{- $nameTpl = "vm.plain.fullname" }}
  {{- end -}}
  {{- include $nameTpl . -}}
{{- end }}

{{- define "vm.fqdn" -}}
  {{- $name := (include "vm.service" .) -}}
  {{- if hasKey . "appIdx" -}}
    {{- $name = (printf "%s-%d.%s" $name .appIdx $name) -}}
  {{- end -}}
  {{- $Values := (.helm).Values | default .Values -}}
  {{- $ns := (include "vm.namespace" .) -}}
  {{- $fqdn := printf "%s.%s.svc" $name $ns -}}
  {{- with (($Values.global).cluster).dnsDomain -}}
    {{- $fqdn = printf "%s.%s" $fqdn . -}}
  {{- end -}}
  {{- $fqdn -}}
{{- end -}}

{{- define "vm.host" -}}
  {{- $fqdn := (include "vm.fqdn" .) -}}
  {{- $port := 80 -}}
  {{- $isSecure := ternary false true (empty .appSecure) -}}
  {{- $Values := (.helm).Values | default .Values -}}
  {{- if .appKey -}}
    {{- $appKey := ternary (list .appKey) .appKey (kindIs "string" .appKey) -}}
    {{- $spec := $Values -}}
    {{- range $ak := $appKey -}}
      {{- if index $spec $ak -}}
        {{- $spec = (index $spec $ak) -}}
      {{- end -}}
      {{- if and (kindIs "map" $spec) (hasKey $spec "spec") -}}
        {{- $spec = $spec.spec -}}
      {{- end -}}
    {{- end -}}
    {{- $isSecure = (eq ($spec.extraArgs).tls "true") | default $isSecure -}}
    {{- $port = (ternary 443 80 $isSecure) -}}
    {{- $port = $spec.port | default ($spec.service).servicePort | default $port -}}
  {{- end }}
  {{- $fqdn }}:{{ $port }}
{{- end -}}

{{- define "vm.url" -}}
  {{- $host := (include "vm.host" .) -}}
  {{- $Values := (.helm).Values | default .Values -}}
  {{- $proto := "http" -}}
  {{- $path := .appRoute | default "/" -}}
  {{- $isSecure := ternary false true (empty .appSecure) -}}
  {{- if .appKey -}}
    {{- $appKey := ternary (list .appKey) .appKey (kindIs "string" .appKey) -}}
    {{- $spec := $Values -}}
    {{- range $ak := $appKey -}}
      {{- if index $spec $ak -}}
        {{- $spec = (index $spec $ak) -}}
      {{- end -}}
      {{- if and (kindIs "map" $spec) (hasKey $spec "spec") -}}
        {{- $spec = $spec.spec -}}
      {{- end -}}
    {{- end -}}
    {{- $isSecure = (eq ($spec.extraArgs).tls "true") | default $isSecure -}}
    {{- $proto = (ternary "https" "http" $isSecure) -}}
    {{- $path = dig "http.pathPrefix" $path ($spec.extraArgs | default dict) -}}
  {{- end -}}
  {{- printf "%s://%s%s" $proto $host $path -}}
{{- end -}}
