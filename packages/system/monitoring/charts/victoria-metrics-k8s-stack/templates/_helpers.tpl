{{- /* Expand the name of the chart. */ -}}
{{- define "victoria-metrics-k8s-stack.name" -}}
  {{- $Chart := (.helm).Chart | default .Chart -}}
  {{- $Values := (.helm).Values | default .Values -}}
  {{- default $Chart.Name $Values.nameOverride | trunc 63 | trimSuffix "-" -}}
{{- end }}

{{- /*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/ -}}
{{- define "victoria-metrics-k8s-stack.fullname" -}}
  {{- $Values := (.helm).Values | default .Values -}}
  {{- $Chart := (.helm).Chart | default .Chart -}}
  {{- $Release := (.helm).Release | default .Release -}}
  {{- $fullname := "" -}}
  {{- if .appKey -}}
    {{- $appKey := ternary (list .appKey) .appKey (kindIs "string" .appKey) -}}
    {{- $values := $Values -}}
    {{- $global := (index $Values.global $Chart.Name) | default dict -}}
    {{- range $ak := $appKey }}
      {{- $values = (index $values $ak) | default dict -}}
      {{- $global = (index $global $ak) | default dict -}}
      {{- if $values.name -}}
        {{- $fullname = $values.name -}}
      {{- else if $global.name -}}
        {{- $fullname = $global.name -}}
      {{- end -}}
    {{- end }}
  {{- end -}}
  {{- if empty $fullname -}}
    {{- if $Values.fullnameOverride -}}
      {{- $fullname = $Values.fullnameOverride -}}
    {{- else if (dig $Chart.Name "fullnameOverride" "" ($Values.global)) -}}
      {{- $fullname = (dig $Chart.Name "fullnameOverride" "" ($Values.global)) -}}
    {{- else -}}
      {{- $name := default $Chart.Name $Values.nameOverride -}}
      {{- if contains $name $Release.Name -}}
        {{- $fullname = $Release.Name -}}
      {{- else -}}
        {{- $fullname = (printf "%s-%s" $Release.Name $name) }}
      {{- end -}}
    {{- end }}
  {{- end -}}
  {{- $fullname | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{- /* Create chart name and version as used by the chart label. */ -}}
{{- define "victoria-metrics-k8s-stack.chart" -}}
  {{- $Chart := (.helm).Chart | default .Chart -}}
  {{- printf "%s-%s" $Chart.Name $Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" -}}
{{- end }}

{{- /* Create the name of the service account to use */ -}}
{{- define "victoria-metrics-k8s-stack.serviceAccountName" -}}
  {{- $Values := (.helm).Values | default .Values -}}
  {{- if $Values.serviceAccount.create -}}
    {{- default (include "victoria-metrics-k8s-stack.fullname" .) $Values.serviceAccount.name -}}
  {{- else -}}
    {{- default "default" $Values.serviceAccount.name -}}
  {{- end }}
{{- end }}

{{- /* Common labels */ -}}
{{- define "victoria-metrics-k8s-stack.labels" -}}
  {{- $Release := (.helm).Release | default .Release -}}
  {{- $Chart := (.helm).Chart | default .Chart -}}
  {{- $labels := (fromYaml (include "victoria-metrics-k8s-stack.selectorLabels" .)) -}}
  {{- $_ := set $labels "helm.sh/chart" (include "victoria-metrics-k8s-stack.chart" .) -}}
  {{- $_ := set $labels "app.kubernetes.io/managed-by" $Release.Service -}}
  {{- with $Chart.AppVersion }}
    {{- $_ := set $labels "app.kubernetes.io/version" . -}}
  {{- end -}}
  {{- toYaml $labels -}}
{{- end }}

{{- define "vm.release" -}}
  {{- $Release := (.helm).Release | default .Release -}}
  {{- $Values := (.helm).Values | default .Values -}}
  {{- default $Release.Name $Values.argocdReleaseOverride | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{- /* Selector labels */ -}}
{{- define "victoria-metrics-k8s-stack.selectorLabels" -}}
  {{- $labels := .extraLabels | default dict -}}
  {{- $_ := set $labels "app.kubernetes.io/name" (include "victoria-metrics-k8s-stack.name" .) -}}
  {{- $_ := set $labels "app.kubernetes.io/instance" (include "vm.release" .) -}}
  {{- toYaml $labels -}}
{{- end }}

{{- /* Create the name for VM service */ -}}
{{- define "vm.service" -}}
  {{- $Values := (.helm).Values | default .Values -}}
  {{- $name := (include "victoria-metrics-k8s-stack.fullname" .) -}}
  {{- with .appKey -}}
    {{- $prefix := . -}}
    {{- if kindIs "slice" $prefix }}
      {{- $prefix = last $prefix -}}
    {{- end -}}
    {{- $prefix = ternary $prefix (printf "vm%s" $prefix) (hasPrefix "vm" $prefix) -}}
    {{- $name = printf "%s-%s" $prefix $name -}}
  {{- end -}}
  {{- if hasKey . "appIdx" -}}
    {{- $name = (printf "%s-%d.%s" $name .appIdx $name) -}}
  {{- end -}}
  {{- $name -}}
{{- end }}

{{- define "vm.url" -}}
  {{- $name := (include "vm.service" .) -}}
  {{- $Release := (.helm).Release | default .Release -}}
  {{- $Values := (.helm).Values | default .Values -}}
  {{- $ns := include "vm.namespace" . -}}
  {{- $proto := "http" -}}
  {{- $port := 80 -}}
  {{- $path := .appRoute | default "/" -}}
  {{- $isSecure := false -}}
  {{- if .appSecure -}}
    {{- $isSecure = .appSecure -}}
  {{- end -}}
  {{- if .appKey -}}
    {{- $appKey := ternary (list .appKey) .appKey (kindIs "string" .appKey) -}}
    {{- $spec := $Values -}}
    {{- range $ak := $appKey -}}
      {{- if hasKey $spec $ak -}}
        {{- $spec = (index $spec $ak) -}}
      {{- end -}}
      {{- if hasKey $spec "spec" -}}
        {{- $spec = $spec.spec -}}
      {{- end -}}
    {{- end -}}
    {{- $isSecure = (eq ($spec.extraArgs).tls "true") | default $isSecure -}}
    {{- $proto = (ternary "https" "http" $isSecure) -}}
    {{- $port = (ternary 443 80 $isSecure) -}}
    {{- $port = $spec.port | default $port -}}
    {{- $path = dig "http.pathPrefix" $path ($spec.extraArgs | default dict) -}}
  {{- end -}}
  {{- printf "%s://%s.%s.svc:%d%s" $proto $name $ns (int $port) $path -}}
{{- end -}}

{{- define "vm.read.endpoint" -}}
  {{- $ctx := . -}}
  {{- $Values := (.helm).Values | default .Values -}}
  {{- $endpoint := default dict -}}
  {{- if $Values.vmsingle.enabled -}}
    {{- $_ := set $ctx "appKey" "vmsingle" -}}
    {{- $_ := set $endpoint "url" (include "vm.url" $ctx) -}}
  {{- else if $Values.vmcluster.enabled -}}
    {{- $_ := set $ctx "appKey" (list "vmcluster" "vmselect") -}}
    {{- $baseURL := (trimSuffix "/" (include "vm.url" $ctx)) -}}
    {{- $tenant := ($Values.tenant | default 0) -}}
    {{- $_ := set $endpoint "url" (printf "%s/select/%d/prometheus" $baseURL (int $tenant)) -}}
  {{- else if $Values.externalVM.read.url -}}
    {{- $endpoint = $Values.externalVM.read -}}
  {{- end -}}
  {{- toYaml $endpoint -}}
{{- end }}

{{- define "vm.write.endpoint" -}}
  {{- $ctx := . -}}
  {{- $Values := (.helm).Values | default .Values -}}
  {{- $endpoint := default dict -}}
  {{- if $Values.vmsingle.enabled -}}
    {{- $_ := set $ctx "appKey" "vmsingle" -}}
    {{- $baseURL := (trimSuffix "/" (include "vm.url" $ctx)) -}}
    {{- $_ := set $endpoint "url" (printf "%s/api/v1/write" $baseURL) -}}
  {{- else if $Values.vmcluster.enabled -}}
    {{- $_ := set $ctx "appKey" (list "vmcluster" "vminsert") -}}
    {{- $baseURL := (trimSuffix "/" (include "vm.url" $ctx)) -}}
    {{- $tenant := ($Values.tenant | default 0) -}}
    {{- $_ := set $endpoint "url" (printf "%s/insert/%d/prometheus/api/v1/write" $baseURL (int $tenant)) -}}
  {{- else if $Values.externalVM.write.url -}}
    {{- $endpoint = $Values.externalVM.write -}}
  {{- end -}}
  {{- toYaml $endpoint -}}
{{- end -}}

{{- /* VMAlert remotes */ -}}
{{- define "vm.alert.remotes" -}}
  {{- $Values := (.helm).Values | default .Values -}}
  {{- $remotes := default dict -}}
  {{- $fullname := (include "victoria-metrics-k8s-stack.fullname" .) -}}
  {{- $ctx := dict "helm" . -}}
  {{- $remoteWrite := (include "vm.write.endpoint" $ctx | fromYaml) -}}
  {{- if $Values.vmalert.remoteWriteVMAgent -}}
    {{- $ctx := dict "helm" . "appKey" "vmagent" -}}
    {{- $remoteWrite = dict "url" (printf "%s/api/v1/write" (include "vm.url" $ctx)) -}}
  {{- end -}}
  {{- $ctx := dict "helm" . -}}
  {{- $remoteRead := (fromYaml (include "vm.read.endpoint" $ctx)) -}}
  {{- $_ := set $remotes "remoteWrite" $remoteWrite -}}
  {{- $_ := set $remotes "remoteRead" $remoteRead -}}
  {{- $_ := set $remotes "datasource" $remoteRead -}}
  {{- if $Values.vmalert.additionalNotifierConfigs }}
    {{- $configName := printf "%s-vmalert-additional-notifier" $fullname -}}
    {{- $notifierConfigRef := dict "name" $configName "key" "notifier-configs.yaml" -}}
    {{- $_ := set $remotes "notifierConfigRef" $notifierConfigRef -}}
  {{- else if $Values.alertmanager.enabled -}}
    {{- $notifiers := default list -}}
    {{- $appSecure := (not (empty (((.Values.alertmanager).spec).webConfig).tls_server_config)) -}}
    {{- $ctx := dict "helm" . "appKey" "alertmanager" "appSecure" $appSecure "appRoute" ((.Values.alertmanager).spec).routePrefix -}}
    {{- $alertManagerReplicas := (.Values.alertmanager.spec.replicaCount | default 1 | int) -}}
    {{- range until $alertManagerReplicas -}}
      {{- $_ := set $ctx "appIdx" . -}}
      {{- $notifiers = append $notifiers (dict "url" (include "vm.url" $ctx)) -}}
    {{- end }}
    {{- $_ := set $remotes "notifiers" $notifiers -}}
  {{- end -}}
  {{- toYaml $remotes -}}
{{- end -}}

{{- /* VMAlert templates */ -}}
{{- define "vm.alert.templates" -}}
  {{- $Values := (.helm).Values | default .Values}}
  {{- $cms :=  ($Values.vmalert.spec.configMaps | default list) -}}
  {{- if $Values.vmalert.templateFiles -}}
    {{- $fullname := (include "victoria-metrics-k8s-stack.fullname" .) -}}
    {{- $cms = append $cms (printf "%s-vmalert-extra-tpl" $fullname) -}}
  {{- end -}}
  {{- $output := dict "configMaps" (compact $cms) -}}
  {{- toYaml $output -}}
{{- end -}}

{{- define "vm.license.global" -}}
  {{- $license := (deepCopy (.Values.global).license) | default dict -}}
  {{- if $license.key -}}
    {{- if hasKey $license "keyRef" -}}
      {{- $_ := unset $license "keyRef" -}}
    {{- end -}}
  {{- else if $license.keyRef.name -}}
    {{- if hasKey $license "key" -}}
      {{- $_ := unset $license "key" -}}
    {{- end -}}
  {{- else -}}
    {{- $license = default dict -}}
  {{- end -}}
  {{- toYaml $license -}}
{{- end -}}

{{- /* VMAlert spec */ -}}
{{- define "vm.alert.spec" -}}
  {{- $Values := (.helm).Values | default .Values }}
  {{- $extraArgs := dict "remoteWrite.disablePathAppend" "true" -}}
  {{- if $Values.vmalert.templateFiles -}}
    {{- $ruleTmpl := (printf "/etc/vm/configs/%s-vmalert-extra-tpl/*.tmpl" (include "victoria-metrics-k8s-stack.fullname" .)) -}}
    {{- $_ := set $extraArgs "rule.templates" $ruleTmpl -}}
  {{- end -}}
  {{- $vmAlertRemotes := (include "vm.alert.remotes" . | fromYaml) -}}
  {{- $vmAlertTemplates := (include "vm.alert.templates" . | fromYaml) -}}
  {{- $spec := dict "extraArgs" $extraArgs -}}
  {{- with (include "vm.license.global" .) -}}
    {{- $_ := set $spec "license" (fromYaml .) -}}
  {{- end -}}
  {{- with concat ($vmAlertRemotes.notifiers | default list) (.Values.vmalert.spec.notifiers | default list) }}
    {{- $_ := set $vmAlertRemotes "notifiers" . }}
  {{- end }}
  {{- $spec := deepCopy (omit $Values.vmalert.spec "notifiers") | mergeOverwrite $vmAlertRemotes | mergeOverwrite $vmAlertTemplates | mergeOverwrite $spec }}
  {{- if not (or (hasKey $spec "notifier") (hasKey $spec "notifiers") (hasKey $spec "notifierConfigRef") (hasKey $spec.extraArgs "notifier.blackhole")) }}
    {{- fail "Neither `notifier`, `notifiers` nor `notifierConfigRef` is set for vmalert. If it's intentionally please consider setting `.vmalert.spec.extraArgs.['notifier.blackhole']` to `'true'`"}}
  {{- end }}
  {{- tpl (deepCopy (omit $Values.vmalert.spec "notifiers") | mergeOverwrite $vmAlertRemotes | mergeOverwrite $vmAlertTemplates | mergeOverwrite $spec | toYaml) . -}}
{{- end }}

{{- /* VM Agent remoteWrites */ -}}
{{- define "vm.agent.remote.write" -}}
  {{- $Values := (.helm).Values | default .Values }}
  {{- $remoteWrites := $Values.vmagent.additionalRemoteWrites | default list -}}
  {{- if or $Values.vmsingle.enabled $Values.vmcluster.enabled $Values.externalVM.write.url -}}
    {{- $ctx := dict "helm" . -}}
    {{- $remoteWrites = append $remoteWrites (fromYaml (include "vm.write.endpoint" $ctx)) -}}
  {{- end -}}
  {{- toYaml (dict "remoteWrite" $remoteWrites) -}}
{{- end -}}

{{- /* VMAgent spec */ -}}
{{- define "vm.agent.spec" -}}
  {{- $Values := (.helm).Values | default .Values }}
  {{- $spec := (include "vm.agent.remote.write" . | fromYaml) -}}
  {{- with (include "vm.license.global" .) -}}
    {{- $_ := set $spec "license" (fromYaml .) -}}
  {{- end -}}
  {{- tpl (deepCopy $Values.vmagent.spec | mergeOverwrite $spec | toYaml) . -}}
{{- end }}

{{- /* VMAuth spec */ -}}
{{- define "vm.auth.spec" -}}
  {{- $ctx := . -}}
  {{- $Values := (.helm).Values | default .Values }}
  {{- $unauthorizedAccessConfig := default list }}
  {{- if $Values.vmsingle.enabled -}}
    {{- $_ := set $ctx "appKey" (list "vmsingle") -}}
    {{- $url := (include "vm.url" $ctx) }}
    {{- $srcPath := clean (printf "%s/.*" (urlParse $url).path) }}
    {{- $unauthorizedAccessConfig = append $unauthorizedAccessConfig (dict "src_paths" (list $srcPath) "url_prefix" (list $url)) }}
  {{- else if $Values.vmcluster.enabled -}}
    {{- $_ := set $ctx "appKey" (list "vmcluster" "vminsert") -}}
    {{- $writeUrl := (include "vm.url" $ctx) }}
    {{- $writeSrcPath := clean (printf "%s/insert/.*" (urlParse $writeUrl).path) }}
    {{- $unauthorizedAccessConfig = append $unauthorizedAccessConfig (dict "src_paths" (list $writeSrcPath) "url_prefix" (list $writeUrl)) }}
    {{- $_ := set $ctx "appKey" (list "vmcluster" "vmselect") -}}
    {{- $readUrl := (include "vm.url" $ctx) }}
    {{- $readSrcPath := clean (printf "%s/select/.*" (urlParse $readUrl).path) }}
    {{- $unauthorizedAccessConfig = append $unauthorizedAccessConfig (dict "src_paths" (list $readSrcPath) "url_prefix" (list $readUrl)) }}
  {{- else if or $Values.externalVM.read.url $Values.externalVM.write.url }}
    {{- with $Values.externalVM.read.url }}
      {{- $srcPath := regexReplaceAll "(.*)/api/.*" (clean (printf "%s/.*" (urlParse .).path)) "${1}" }}
      {{- $unauthorizedAccessConfig = append $unauthorizedAccessConfig (dict "src_paths" (list $srcPath) "url_prefix" (list .)) }}
    {{- end -}}
    {{- with $Values.externalVM.write.url }}
      {{- $srcPath := regexReplaceAll "(.*)/api/.*" (clean (printf "%s/.*" (urlParse .).path)) "${1}" }}
      {{- $unauthorizedAccessConfig = append $unauthorizedAccessConfig (dict "src_paths" (list $srcPath) "url_prefix" (list .)) }}
    {{- end -}}
  {{- end -}}
  {{- $spec := $Values.vmauth.spec }}
  {{- $_ := set $spec "unauthorizedAccessConfig" (concat $unauthorizedAccessConfig ($spec.unauthorizedAccessConfig | default list)) }}
  {{- with (include "vm.license.global" .) -}}
    {{- $_ := set $spec "license" (fromYaml .) -}}
  {{- end -}}
  {{- tpl (toYaml $spec) . -}}
{{- end -}}

{{- /* Alermanager spec */ -}}
{{- define "vm.alertmanager.spec" -}}
  {{- $Values := (.helm).Values | default .Values }}
  {{- $fullname := (include "victoria-metrics-k8s-stack.fullname" .) -}}
  {{- $spec := $Values.alertmanager.spec -}}
  {{- if and (not $Values.alertmanager.spec.configRawYaml) (not $Values.alertmanager.spec.configSecret) -}}
    {{- $_ := set $spec "configSecret" (printf "%s-alertmanager" $fullname) -}}
  {{- end -}}
  {{- $templates := default list -}}
  {{- if $Values.alertmanager.monzoTemplate.enabled -}}
    {{- $configMap := (printf "%s-alertmanager-monzo-tpl" $fullname) -}}
    {{- $templates = append $templates (dict "name" $configMap "key" "monzo.tmpl") -}}
  {{- end -}}
  {{- $configMap := (printf "%s-alertmanager-extra-tpl" $fullname) -}}
  {{- range $key, $value := (.Values.alertmanager.templateFiles | default dict) -}}
    {{- $templates = append $templates (dict "name" $configMap "key" $key) -}}
  {{- end -}}
  {{- $_ := set $spec "templates" $templates -}}
  {{- toYaml $spec -}}
{{- end -}}

{{- /* Single spec */ -}}
{{- define "vm.single.spec" -}}
  {{- $Values := (.helm).Values | default .Values }}
  {{- $extraArgs := default dict -}}
  {{- if $Values.vmalert.enabled }}
    {{- $ctx := dict "helm" . "appKey" "vmalert" -}}
    {{- $_ := set $extraArgs "vmalert.proxyURL" (include "vm.url" $ctx) -}}
  {{- end -}}
  {{- $spec := dict "extraArgs" $extraArgs -}}
  {{- with (include "vm.license.global" .) -}}
    {{- $_ := set $spec "license" (fromYaml .) -}}
  {{- end -}}
  {{- tpl (deepCopy $Values.vmsingle.spec | mergeOverwrite $spec | toYaml) . -}}
{{- end }}

{{- /* Cluster spec */ -}}
{{- define "vm.select.spec" -}}
  {{- $Values := (.helm).Values | default .Values }}
  {{- $extraArgs := default dict -}}
  {{- if $Values.vmalert.enabled -}}
    {{- $ctx := dict "helm" . "appKey" "vmalert" -}}
    {{- $_ := set $extraArgs "vmalert.proxyURL" (include "vm.url" $ctx) -}}
  {{- end -}}
  {{- $spec := dict "extraArgs" $extraArgs -}}
  {{- toYaml $spec -}}
{{- end -}}

{{- define "vm.cluster.spec" -}}
  {{- $Values := (.helm).Values | default .Values }}
  {{- $spec := (include "vm.select.spec" . | fromYaml) -}}
  {{- $clusterSpec := (deepCopy $Values.vmcluster.spec) -}}
  {{- with (include "vm.license.global" .) -}}
    {{- $_ := set $clusterSpec "license" (fromYaml .) -}}
  {{- end -}}
  {{- tpl ($clusterSpec | mergeOverwrite (dict "vmselect" $spec) | toYaml) . -}}
{{- end -}}

{{- define "vm.data.source.enabled" -}}
  {{- $Values := (.helm).Values | default .Values -}}
  {{- $grafana := $Values.grafana -}}
  {{- $isEnabled := false -}}
  {{- if $grafana.plugins -}}
    {{- range $value := $grafana.plugins -}}
      {{- if contains "victoriametrics-datasource" $value -}}
        {{- $isEnabled = true -}}
      {{- end }}
    {{- end }}
  {{- end }}
  {{- $unsignedPlugins := ((index $grafana "grafana.ini").plugins).allow_loading_unsigned_plugins | default "" -}}
  {{- $allowUnsigned := contains "victoriametrics-datasource" $unsignedPlugins -}}
  {{- ternary "true" "" (and $isEnabled $allowUnsigned) -}}
{{- end -}}

{{- /* Datasources */ -}}
{{- define "vm.data.sources" -}}
  {{- $Values := (.helm).Values | default .Values }}
  {{- $grafana := $Values.grafana -}}
  {{- $datasources := $Values.grafana.additionalDataSources | default list -}}
  {{- $vmDatasource := "victoriametrics-datasource" -}}
  {{- $allowVMDatasource := (ternary false true (empty (include "vm.data.source.enabled" .))) -}}
  {{- if or $Values.vmsingle.enabled $Values.vmcluster.enabled -}}
    {{- $ctx := dict "helm" . -}}
    {{- $readEndpoint:= (include "vm.read.endpoint" $ctx | fromYaml) -}}
    {{- $defaultDatasources := default list -}}
    {{- range $ds := $grafana.sidecar.datasources.default }}
      {{- if not $ds.type -}}
        {{- $_ := set $ds "type" $Values.grafana.defaultDatasourceType }}
      {{- end -}}
      {{- if or (ne $ds.type $vmDatasource) $allowVMDatasource -}}
        {{- $_ := set $ds "url" $readEndpoint.url -}}
        {{- $defaultDatasources = append $defaultDatasources $ds -}}
      {{- end -}}
    {{- end }}
    {{- $datasources = concat $datasources $defaultDatasources -}}
    {{- if and $grafana.sidecar.datasources.createVMReplicasDatasources $defaultDatasources -}}
      {{- range $id := until (int $Values.vmsingle.spec.replicaCount) -}}
        {{- $_ := set $ctx "appIdx" $id -}}
        {{- $readEndpoint := (include "vm.read.endpoint" $ctx | fromYaml) -}}
        {{- range $ds := $defaultDatasources -}}
          {{- $ds = (deepCopy $ds) -}}
          {{- $_ := set $ds "url" $readEndpoint.url -}}
          {{- $_ := set $ds "name" (printf "%s-%d" $ds.name $id) -}}
          {{- $_ := set $ds "isDefault" false -}}
          {{- $datasources = append $datasources $ds -}}
        {{- end -}}
      {{- end -}}
    {{- end -}}
  {{- end -}}
  {{- toYaml $datasources -}}
{{- end }}

{{- /* VMRule name */ -}}
{{- define "victoria-metrics-k8s-stack.rulegroup.name" -}}
  {{- printf "%s-%s" (include "victoria-metrics-k8s-stack.fullname" .) (.name | replace "_" "") -}}
{{- end -}}

{{- /* VMRule labels */ -}}
{{- define "victoria-metrics-k8s-stack.rulegroup.labels" -}}
  {{- $Values := (.helm).Values | default .Values }}
  {{- $labels := (fromYaml (include "victoria-metrics-k8s-stack.labels" .)) -}}
  {{- $_ := set $labels "app" (include "victoria-metrics-k8s-stack.name" .) -}}
  {{- $labels = mergeOverwrite $labels (deepCopy $Values.defaultRules.labels) -}}
  {{- toYaml $labels -}}
{{- end }}

{{- /* VMRule key */ -}}
{{- define "victoria-metrics-k8s-stack.rulegroup.key" -}}
  {{- without (regexSplit "[-_.]" .name -1) "exporter" "rules" | join "-" | camelcase | untitle -}}
{{- end -}}

{{- /* VMAlertmanager name */ -}}
{{- define "victoria-metrics-k8s-stack.alertmanager.name" -}}
  {{- $Values := (.helm).Values | default .Values }}
  {{- $Values.alertmanager.name | default (printf "%s-%s" "vmalertmanager" (include "victoria-metrics-k8s-stack.fullname" .) | trunc 63 | trimSuffix "-") -}}
{{- end -}}
