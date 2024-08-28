{{- define "vm.enterprise.only" -}}
  {{- $license := .Values.license | default dict -}}
  {{- if and (empty $license.key) (empty (dig "secret" "name" "" $license)) (not .Values.eula) -}}
    {{ fail "Pass -eula command-line flag or valid license at .Values.license if you have an enterprise license for running this software. See https://victoriametrics.com/legal/esa/ for details"}}
  {{- end -}}
{{- end -}}
