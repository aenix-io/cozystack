NAME=mariadb-operator
NAMESPACE=cozy-mariadb-operator

show:
	helm template --dry-run=server -n $(NAMESPACE) $(NAME) .

apply:
	helm upgrade -i -n $(NAMESPACE) $(NAME) .

diff:
	helm diff upgrade --allow-unreleased --normalize-manifests -n $(NAMESPACE) $(NAME) .

update:
	rm -rf charts
	helm repo add mariadb-operator https://mariadb-operator.github.io/mariadb-operator
	helm repo update mariadb-operator
	helm pull mariadb-operator/mariadb-operator --untar --untardir charts
