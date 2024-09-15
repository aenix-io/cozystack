{{- define "vm.port.from.flag" -}}
{{- $port := .default -}}
{{- with .flag -}}
{{- $port = regexReplaceAll ".*:(\\d+)" . "${1}" -}}
{{- end -}}
{{- $port -}}
{{- end }}

{{- /*
Return true if the detected platform is Openshift
Usage:
{{- include "vm.compatibility.isOpenshift" . -}}
*/ -}}
{{- define "vm.compatibility.isOpenshift" -}}
{{- if .Capabilities.APIVersions.Has "security.openshift.io/v1" -}}
{{- true -}}
{{- end -}}
{{- end -}}

{{- /*
Render a compatible securityContext depending on the platform. By default it is maintained as it is. In other platforms like Openshift we remove default user/group values that do not work out of the box with the restricted-v1 SCC
Usage:
{{- include "vm.compatibility.renderSecurityContext" (dict "secContext" .Values.containerSecurityContext "context" $) -}}
*/ -}}
{{- define "vm.compatibility.renderSecurityContext" -}}
{{- $adaptedContext := .secContext -}}
{{- $adaptSecurityCtx := ((((.context.Values).global).compatibility).openshift).adaptSecurityContext | default "" -}}
{{- if or (eq $adaptSecurityCtx "force") (and (eq $adaptSecurityCtx "auto") (include "vm.compatibility.isOpenshift" .context)) -}}
  {{- /* Remove incompatible user/group values that do not work in Openshift out of the box */ -}}
  {{- $adaptedContext = omit $adaptedContext "fsGroup" "runAsUser" "runAsGroup" -}}
  {{- if not .secContext.seLinuxOptions -}} 
    {{- /* If it is an empty object, we remove it from the resulting context because it causes validation issues */ -}}
    {{- $adaptedContext = omit $adaptedContext "seLinuxOptions" -}}
  {{- end -}}
{{- end -}}
{{- omit $adaptedContext "enabled" | toYaml -}}
{{- end -}}

{{- /*
Render probe
*/ -}}
{{- define "vm.probe" -}}
  {{- /* undefined value */ -}}
  {{- $null := (fromYaml "value: null").value -}}
  {{- $probe := dig .type (default dict) .app.probe -}}
  {{- $probeType := "" -}}
  {{- $defaultProbe := default dict -}}
  {{- if ne (dig "httpGet" $null $probe) $null -}}
    {{- /* httpGet probe */ -}}
    {{- $defaultProbe = dict "path" (include "vm.probe.http.path" .) "scheme" (include "vm.probe.http.scheme" .) "port" (include "vm.probe.port" .) -}}
    {{- $probeType = "httpGet" -}}
  {{- else if ne (dig "tcpSocket" $null $probe) $null -}}
    {{- /* tcpSocket probe */ -}}
    {{- $defaultProbe = dict "port" (include "vm.probe.port" .) -}}
    {{- $probeType = "tcpSocket" -}}
  {{- end -}}
  {{- $defaultProbe = ternary (default dict) (dict $probeType $defaultProbe) (empty $probeType) -}}
  {{- $probe = mergeOverwrite $defaultProbe $probe -}}
  {{- range $key, $value := $probe -}}
    {{- if and (has (kindOf $value) (list "object" "map")) (ne $key $probeType) -}}
      {{- $_ := unset $probe $key -}}
    {{- end -}}
  {{- end -}}
  {{- tpl (toYaml $probe) . -}}
{{- end -}}

{{- /*
HTTP GET probe path
*/ -}}
{{- define "vm.probe.http.path" -}}
{{- index .app.extraArgs "http.pathPrefix" | default "" | trimSuffix "/" -}}/health
{{- end -}}

{{- /*
HTTP GET probe scheme
*/ -}}
{{- define "vm.probe.http.scheme" -}}
{{- ternary "HTTPS" "HTTP" (.app.extraArgs.tls | default false) -}}
{{- end -}}

{{- /*
Net probe port
*/ -}}
{{- define "vm.probe.port" -}}
{{- dig "ports" "name" "http" (.app | dict) -}}
{{- end -}}

{{- define "vm.arg" -}}
{{- if and (kindIs "bool" .value) .value -}}
-{{ .key }}
{{- else -}}
-{{ .key }}={{ .value }}
{{- end -}}
{{- end -}}

{{- /*
command line arguments
*/ -}}
{{- define "vm.args" -}}
{{- $args := default list -}}
{{- range $key, $value := . -}}
{{- if kindIs "slice" $value -}}
{{- range $v := $value -}}
{{- $args = append $args (include "vm.arg" (dict "key" $key "value" $v)) -}}
{{- end -}}
{{- else -}}
{{- $args = append $args (include "vm.arg" (dict "key" $key "value" $value)) -}}
{{- end -}}
{{- end -}}
{{- toYaml $args -}}
{{- end -}}
