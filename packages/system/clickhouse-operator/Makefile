NAME=clickhouse-operator
NAMESPACE=cozy-clickhouse-operator

show:
	helm template --dry-run=server -n $(NAMESPACE) $(NAME) .

apply:
	helm upgrade -i -n $(NAMESPACE) $(NAME) .

diff:
	helm diff upgrade --allow-unreleased --normalize-manifests -n $(NAMESPACE) $(NAME) .

update:
	rm -rf charts
	helm repo add clickhouse-operator https://docs.altinity.com/clickhouse-operator/
	helm repo update clickhouse-operator
	helm pull clickhouse-operator/altinity-clickhouse-operator --untar --untardir charts
