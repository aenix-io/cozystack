NAME=grafana-operator
NAMESPACE=cozy-grafana-operator

show:
	helm template -n $(NAMESPACE) $(NAME) .

apply:
	helm upgrade -i -n $(NAMESPACE) $(NAME) .

diff:
	helm diff upgrade --allow-unreleased -n $(NAMESPACE) $(NAME) .

update:
	rm -rf charts
	mkdir -p charts
	curl -sSL https://github.com/grafana-operator/grafana-operator/archive/refs/heads/master.tar.gz | \
	tar xzvf - --strip 3 -C charts grafana-operator-master/deploy/helm/grafana-operator
