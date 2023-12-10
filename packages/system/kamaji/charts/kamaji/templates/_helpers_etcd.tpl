{{/*
Create a default fully qualified etcd name.
*/}}
{{- define "etcd.fullname" -}}
{{- printf "etcd" }}
{{- end }}

{{/*
Create the name of the service account to use
*/}}
{{- define "etcd.serviceAccountName" -}}
{{- if .Values.etcd.serviceAccount.create }}
{{- default (include "etcd.fullname" .) .Values.etcd.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.etcd.serviceAccount.name }}
{{- end }}
{{- end }}

{{/*
Create the name of the Service to use
*/}}
{{- define "etcd.serviceName" -}}
{{- printf "%s" (include "etcd.fullname" .) | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "etcd.labels" -}}
app.kubernetes.io/name: {{ include "kamaji.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
app.kubernetes.io/components: etcd
{{- end }}

{{/*
Selector labels.
*/}}
{{- define "etcd.selectorLabels" -}}
app.kubernetes.io/name: {{ include "kamaji.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
app.kubernetes.io/component: etcd
{{- end }}

{{/*
Name of the etcd CA secret.
*/}}
{{- define "etcd.caSecretName" }}
{{- if .Values.etcd.deploy }}
{{- printf "%s-%s" (include "etcd.fullname" .) "certs" | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- required "A valid .Values.etcd.overrides.caSecret.name required!" .Values.etcd.overrides.caSecret.name }}
{{- end }}
{{- end }}

{{/*
Namespace of the etcd CA secret.
*/}}
{{- define "etcd.caSecretNamespace" }}
{{- if .Values.etcd.deploy }}
{{- .Release.Namespace }}
{{- else }}
{{- required "A valid .Values.etcd.overrides.caSecret.namespace required!" .Values.etcd.overrides.caSecret.namespace }}
{{- end }}
{{- end }}

{{/*
Name of the certificate signing requests for the certificates required by etcd.
*/}}
{{- define "etcd.csrConfigMapName" }}
{{- printf "%s-csr" (include "etcd.fullname" .) }}
{{- end }}

{{/*
Name of the etcd root-client secret.
*/}}
{{- define "etcd.clientSecretName" }}
{{- if .Values.etcd.deploy }}
{{- printf "root-client-certs" }}
{{- else }}
{{- required "A valid .Values.etcd.overrides.clientSecret.name required!" .Values.etcd.overrides.clientSecret.name }}
{{- end }}
{{- end }}

{{/*
Namespace of the etcd root-client secret.
*/}}
{{- define "etcd.clientSecretNamespace" }}
{{- if .Values.etcd.deploy }}
{{- .Release.Namespace }}
{{- else }}
{{- required "A valid .Values.etcd.overrides.clientSecret.namespace required!" .Values.etcd.overrides.clientSecret.namespace }}
{{- end }}
{{- end }}

{{/*
Comma separated list of etcd endpoints, using the overrides in case of unmanaged etcd.
*/}}
{{- define "etcd.endpoints" }}
{{- $list := list -}}
{{- if .Values.etcd.deploy }}
    {{- range $count := until 3 -}}
        {{- $list = append $list (printf "%s-%d.%s.%s.svc.cluster.local:%d" "etcd" $count ( include "etcd.serviceName" . ) $.Release.Namespace (int $.Values.etcd.port) ) -}}
    {{- end }}
{{- else if .Values.etcd.overrides.endpoints }}
    {{- range $v := .Values.etcd.overrides.endpoints -}}
        {{- $list = append $list (printf "%s:%d" $v (int $.Values.etcd.port) ) -}}
    {{- end -}}
{{- else if not .Values.etcd.overrides.endpoints }}
    {{- fail "A valid .Values.etcd.overrides.endpoints required!" }}
{{- end }}
{{- $list | toYaml }}
{{- end }}

{{/*
Key-value of the etcd peers, using the overrides in case of unmanaged etcd.
*/}}
{{- define "etcd.initialCluster" }}
{{- $list := list -}}
{{- if .Values.etcd.deploy }}
    {{- range $i, $count := until 3 -}}
        {{- $list = append $list ( printf "etcd-%d=https://%s-%d.%s.%s.svc.cluster.local:%d" $i "etcd" $count ( include "etcd.serviceName" . ) $.Release.Namespace (int $.Values.etcd.peerApiPort) ) -}}
    {{- end }}
{{- else if .Values.etcd.overrides.endpoints }}
    {{- range $k, $v := .Values.etcd.overrides.endpoints -}}
        {{- $list = append $list ( printf "%s=%s:%d" $k $v (int $.Values.etcd.peerApiPort) ) -}}
    {{- end -}}
{{- else if not .Values.etcd.overrides.endpoints }}
    {{- fail "A valid .Values.etcd.overrides.endpoints required!" }}
{{- end }}
{{- join "," $list -}}
{{- end }}

{{/*
Retrieve the current Kubernetes version to launch a kubectl container with the minimum version skew possible.
*/}}
{{- define "etcd.jobsTagKubeVersion" -}}
{{- if contains "-eks-" .Capabilities.KubeVersion.GitVersion }}
{{- print "v" .Capabilities.KubeVersion.Major "." (.Capabilities.KubeVersion.Minor | replace "+" "") -}}
{{- else }}
{{- print "v" .Capabilities.KubeVersion.Major "." .Capabilities.KubeVersion.Minor -}}
{{- end }}
{{- end }}
