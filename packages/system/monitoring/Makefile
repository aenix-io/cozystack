NAME=monitoring
NAMESPACE=cozy-monitoring

show:
	helm template -n $(NAMESPACE) $(NAME) .

apply:
	helm upgrade -i -n $(NAMESPACE) $(NAME) .

diff:
	helm diff upgrade --allow-unreleased -n $(NAMESPACE) $(NAME) .

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
