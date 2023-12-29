NAMESPACE=cozy-fluxcd
NAME=fluxcd

show:
	helm template -n $(NAMESPACE) $(NAME) .

apply:
	helm upgrade -i -n $(NAMESPACE) $(NAME) .

diff:
	helm diff upgrade --allow-unreleased -n $(NAMESPACE) $(NAME) .

update:
	rm -rf charts
	helm pull oci://ghcr.io/fluxcd-community/charts/flux2 --untar --untardir charts
