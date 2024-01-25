NAME=kamaji
NAMESPACE=cozy-kamaji

show:
	helm template --dry-run=server -n $(NAMESPACE) $(NAME) .

apply:
	helm upgrade -i -n $(NAMESPACE) $(NAME) .

diff:
	helm diff upgrade --allow-unreleased --normalize-manifests -n $(NAMESPACE) $(NAME) .

update:
	rm -rf charts
	helm repo add clastix https://clastix.github.io/charts
	helm repo update clastix
	helm pull clastix/kamaji --untar --untardir charts
