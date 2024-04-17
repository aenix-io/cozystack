{{/*
Expand the name of the chart.
*/}}
{{- define "etcd.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified etcd name.
*/}}
{{- define "etcd.fullname" -}}
{{- if .Values.fullnameOverride -}}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- $name := default .Chart.Name .Values.nameOverride -}}
{{- if contains $name .Release.Name -}}
{{- .Release.Name | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" -}}
{{- end -}}
{{- end -}}
{{- end -}}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "etcd.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create the etcd fully-qualified Docker image to use
*/}}
{{- define "etcd.fullyQualifiedDockerImage" -}}
{{- printf "%s:%s" .Values.image.repository ( .Values.image.tag | default (printf "v%s" .Chart.AppVersion) ) -}}
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
helm.sh/chart: {{ include "etcd.chart" . }}
{{ include "etcd.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "etcd.selectorLabels" -}}
app.kubernetes.io/name: {{ include "etcd.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Create the name of the service account to use
*/}}
{{- define "etcd.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- default (include "etcd.fullname" .) .Values.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}

{{/*
Name of the Stateful Set.
*/}}
{{- define "etcd.stsName" }}
{{- printf "%s" (include "etcd.fullname" .) | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Name of the etcd CA secret.
*/}}
{{- define "etcd.caSecretName" }}
{{- printf "%s-%s" (include "etcd.fullname" .) "certs" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Name of the certificate signing requests for the certificates required by etcd.
*/}}
{{- define "etcd.csrConfigMapName" }}
{{- printf "%s-csr" (include "etcd.fullname" .) }}
{{- end }}

{{/*
Name of the etcd role
*/}}
{{- define "etcd.roleName" }}
{{- printf "%s-gen-certs-role" (include "etcd.fullname" .) }}
{{- end }}

{{/*
Name of the etcd role binding
*/}}
{{- define "etcd.roleBindingName" }}
{{- printf "%s-gen-certs-rolebiding" (include "etcd.fullname" .) }}
{{- end }}

{{/*
Name of the etcd root-client secret.
*/}}
{{- define "etcd.clientSecretName" }}
{{- printf "%s-root-client-certs" ( include "etcd.fullname" . ) }}
{{- end }}

{{/*
Retrieve the current Kubernetes version to launch a kubectl container with the minimum version skew possible.
*/}}
{{- define "etcd.jobsTagKubeVersion" -}}
{{- print "v" .Capabilities.KubeVersion.Major "." (.Capabilities.KubeVersion.Minor | replace "+" "") -}}
{{- end }}

{{/*
Comma separated list of etcd cluster peers.
*/}}
{{- define "etcd.initialCluster" }}
{{- $outer := . -}}
{{- $list := list -}}
{{- range $i, $count := until (int $.Values.replicas) -}}
    {{- $list = append $list ( printf "%s-%d=https://%s-%d.%s.%s.svc.cluster.local:%d" ( include "etcd.stsName" $outer ) $i ( include "etcd.fullname" $outer ) $count ( include "etcd.serviceName" $outer ) $.Release.Namespace (int $.Values.peerApiPort) ) -}}
{{- end }}
{{- join "," $list -}}
{{- end }}

{{/*
Space separated list of etcd cluster endpoints.
*/}}
{{- define "etcd.endpoints" }}
{{- $outer := . -}}
{{- $list := list -}}
{{- range $i, $count := until (int $.Values.replicas) -}}
    {{- $list = append $list ( printf "%s-%d.%s.%s.svc.cluster.local:%d" ( include "etcd.stsName" $outer ) $count ( include "etcd.serviceName" $outer ) $.Release.Namespace (int $.Values.clientPort) ) -}}
{{- end }}
{{- join " " $list -}}
{{- end }}

{{/*
Space separated list of etcd cluster endpoints.
*/}}
{{- define "etcd.endpointsYAML" }}
{{- $outer := . -}}
{{- range $i, $count := until (int $.Values.replicas) -}}
    {{ printf "- %s-%d.%s.%s.svc.cluster.local:%d\n" ( include "etcd.stsName" $outer ) $count ( include "etcd.serviceName" $outer ) $.Release.Namespace (int $.Values.clientPort) }}
{{- end }}
{{- end }}

{{/*
Create the minio-client fully-qualified Docker image to use
*/}}
{{- define "minio-client.fullyQualifiedDockerImage" -}}
{{- printf "%s:%s" .Values.backup.s3.image.repository .Values.backup.s3.image.tag -}}
{{- end }}
