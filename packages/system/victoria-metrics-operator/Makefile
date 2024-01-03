NAME=victoria-metrics-operator
NAMESPACE=cozy-victoria-metrics-operator

show:
	helm template --dry-run=server -n $(NAMESPACE) $(NAME) .

apply:
	helm upgrade -i -n $(NAMESPACE) $(NAME) .

diff:
	helm diff upgrade --allow-unreleased --normalize-manifests -n $(NAMESPACE) $(NAME) .

update:
	rm -rf charts
	# VictoriaMetrics operator
	helm repo add vm https://victoriametrics.github.io/helm-charts/
	helm repo update vm
	helm pull vm/victoria-metrics-operator --untar --untardir charts
	# Prometheus CRDs
	helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
	helm repo update prometheus-community
	helm pull prometheus-community/prometheus-operator-crds --untar --untardir charts
	rm -f -- `find charts/prometheus-operator-crds/templates -maxdepth 1 -mindepth 1 | grep -v 'servicemonitor\|podmonitor\|prometheusrule\|probe'`
