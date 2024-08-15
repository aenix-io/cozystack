export NAME=grafana-operator
export NAMESPACE=cozy-grafana-operator

include ../../../scripts/package.mk

update:
	rm -rf charts
	mkdir -p charts
	curl -sSL https://github.com/grafana-operator/grafana-operator/archive/refs/heads/master.tar.gz | \
	tar xzvf - --strip 3 -C charts grafana-operator-master/deploy/helm/grafana-operator
