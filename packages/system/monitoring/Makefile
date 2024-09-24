export NAME=monitoring
export NAMESPACE=cozy-$(NAME)

include ../../../scripts/package.mk

update:
	rm -rf charts
	helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
	helm repo update prometheus-community
	# Kube-state-metrics
	helm pull prometheus-community/kube-state-metrics --untar --untardir charts
	# Node-exporter
	helm pull prometheus-community/prometheus-node-exporter --untar --untardir charts
	# Metrics-server
	helm repo add metrics-server https://kubernetes-sigs.github.io/metrics-server/
	helm repo update metrics-server
	helm pull metrics-server/metrics-server --untar --untardir charts
	# Fluent-bit
	helm repo add fluent https://fluent.github.io/helm-charts
	helm repo update fluent
	helm pull fluent/fluent-bit --untar --untardir charts
	# alerts from victoria-metrics-k8s-stack
	helm repo add vm https://victoriametrics.github.io/helm-charts/
	helm repo update vm
	helm pull vm/victoria-metrics-k8s-stack --untar --untardir charts
	rm -rf charts/victoria-metrics-k8s-stack/charts
	rm -rf charts/victoria-metrics-k8s-stack/hack
	rm -rf charts/victoria-metrics-k8s-stack/templates/victoria-metrics-operator
	rm -rf charts/victoria-metrics-k8s-stack/templates/grafana
	rm -rf charts/victoria-metrics-k8s-stack/templates/ingress.yaml
	rm -rf charts/victoria-metrics-k8s-stack/files/dashboards
	rm -f charts/victoria-metrics-k8s-stack/templates/servicemonitors.yaml
	rm -f charts/victoria-metrics-k8s-stack/templates/serviceaccount.yaml
	rm -f charts/victoria-metrics-k8s-stack/templates/rules/additionalVictoriaMetricsRules.yml
	sed -i '/  namespace:/d' charts/victoria-metrics-k8s-stack/templates/rules/rule.yaml
	sed -i 's|job="apiserver"|job="kube-apiserver"|g' `grep -rl 'job="apiserver"' charts/victoria-metrics-k8s-stack/files/rules/generated`
	sed -i 's|severity: info|severity: informational|g' `grep -rl 'severity: info' ./charts/victoria-metrics-k8s-stack/files/rules/generated`
	sed -i 's|severity: none|severity: ok|g' ./charts/victoria-metrics-k8s-stack/files/rules/generated/general.rules.yaml
	sed -i ./charts/victoria-metrics-k8s-stack/files/rules/generated/general.rules.yaml \
		-e '/Watchdog/,/severity:/s/severity: none/severity: ok/' \
		-e '/InfoInhibitor/,/severity:/s/severity: none/severity: major/' 
	# TODO
	rm -f charts/victoria-metrics-k8s-stack/files/rules/generated/alertmanager.rules.yaml
	rm -f charts/victoria-metrics-k8s-stack/files/rules/generated/vm*.yaml
