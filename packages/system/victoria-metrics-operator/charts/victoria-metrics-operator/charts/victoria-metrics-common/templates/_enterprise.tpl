{{- define "vm.license.secret.key" -}}
{{- ((.Values.license).secret).key | default (((.Values.global).license).secret).key | default "" -}}
{{- end -}}

{{- define "vm.license.secret.name" -}}
{{- ((.Values.license).secret).name | default (((.Values.global).license).secret).name | default "" -}}
{{- end -}}

{{- define "vm.license.key" -}}
{{- (.Values.license).key | default ((.Values.global).license).key | default "" -}}
{{- end -}}

{{- define "vm.enterprise.only" -}}
  {{- $licenseKey := (include "vm.license.key" .) -}}
  {{- $licenseSecretKey := (include "vm.license.secret.key" .) -}}
  {{- $licenseSecretName := (include "vm.license.secret.name" .) -}}
  {{- $eula := or .Values.eula ((.Values.global).eula | default false) -}}
  {{- if and (empty $licenseKey) (and (empty $licenseSecretName) (empty $licenseSecretKey)) (not $eula) -}}
    {{ fail "Pass -eula command-line flag or valid license at .Values.license or .Values.global.license if you have an enterprise license for running this software. See https://victoriametrics.com/legal/esa/ for details"}}
  {{- end -}}
{{- end -}}

{{/*
Return license volume mount
*/}}
{{- define "vm.license.volume" -}}
{{- $licenseSecretKey := (include "vm.license.secret.key" .) -}}
{{- $licenseSecretName := (include "vm.license.secret.name" .) -}}
{{- if and $licenseSecretName $licenseSecretKey -}}
- name: license-key
  secret:
    secretName: {{ $licenseSecretName }}
{{- end -}}
{{- end -}}

{{/*
Return license volume mount for container
*/}}
{{- define "vm.license.mount" -}}
{{- $licenseSecretKey := (include "vm.license.secret.key" .) -}}
{{- $licenseSecretName := (include "vm.license.secret.name" .) -}}
{{- if and $licenseSecretName $licenseSecretKey -}}
- name: license-key
  mountPath: /etc/vm-license-key
  readOnly: true
{{- end -}}
{{- end -}}

{{/*
Return license flag if necessary.
*/}}
{{- define "vm.license.flag" -}}
{{- $licenseKey := (include "vm.license.key" .) -}}
{{- $licenseSecretKey := (include "vm.license.secret.key" .) -}}
{{- $licenseSecretName := (include "vm.license.secret.name" .) -}}
{{- if $licenseKey -}}
license: {{ $licenseKey }}
{{- else if and $licenseSecretName $licenseSecretKey -}}
licenseFile: /etc/vm-license-key/{{ $licenseSecretKey }}
{{- end -}}
{{- end -}}
