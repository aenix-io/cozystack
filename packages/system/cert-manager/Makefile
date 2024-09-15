export NAME=cert-manager
export NAMESPACE=cozy-$(NAME)

include ../../../scripts/package.mk

update:
	rm -rf charts
	helm repo add jetstack https://charts.jetstack.io
	helm repo update jetstack
	helm pull jetstack/cert-manager --untar --untardir charts
