NAME=redis-operator
NAMESPACE=cozy-redis-operator

show:
	helm template --dry-run=server -n $(NAMESPACE) $(NAME) .

apply:
	helm upgrade -i -n $(NAMESPACE) $(NAME) .

diff:
	helm diff upgrade --allow-unreleased --normalize-manifests -n $(NAMESPACE) $(NAME) .

update:
	rm -rf charts
	helm repo add redis-operator https://spotahome.github.io/redis-operator
	helm repo update redis-operator
	helm pull redis-operator/redis-operator --untar --untardir charts
	sed -i '/{{/d' charts/redis-operator/crds/databases.spotahome.com_redisfailovers.yaml
