NAME=fluxcd
NAMESPACE=cozy-$(NAME)

include ../../../scripts/package.mk

apply-locally:
	helm upgrade -i -n $(NAMESPACE) $(NAME) .

update:
	rm -rf charts
	helm pull oci://ghcr.io/controlplaneio-fluxcd/charts/flux-instance --untar --untardir charts
