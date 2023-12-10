NAME=capi-operator
NAMESPACE=cozy-cluster-api

show:
	helm template --dry-run=server -n $(NAMESPACE) $(NAME) .

apply:
	helm upgrade -i -n $(NAMESPACE) $(NAME) .

diff:
	helm diff upgrade --allow-unreleased --normalize-manifests -n $(NAMESPACE) $(NAME) .

update:
	rm -rf charts
	helm repo add capi-operator https://kubernetes-sigs.github.io/cluster-api-operator
	helm repo update capi-operator
	helm pull capi-operator/cluster-api-operator --untar --untardir charts
	rm -rf charts/cluster-api-operator/charts
