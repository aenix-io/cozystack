NAME=kamaji
NAMESPACE=cozy-$(NAME)

include ../../../hack/package-system.mk

update:
	rm -rf charts
	helm repo add clastix https://clastix.github.io/charts
	helm repo update clastix
	helm pull clastix/kamaji --untar --untardir charts
