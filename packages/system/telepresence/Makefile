NAME=traffic-manager
NAMESPACE=cozy-telepresence

show:
	helm template --dry-run=server -n $(NAMESPACE) $(NAME) .

apply:
	helm upgrade -i -n $(NAMESPACE) $(NAME) .

diff:
	helm diff upgrade --allow-unreleased --normalize-manifests -n $(NAMESPACE) $(NAME) .

update:
	rm -rf charts
	helm repo add datawire https://app.getambassador.io
	helm repo update datawire
	helm pull datawire/telepresence --untar --untardir charts
