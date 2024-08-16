NAME=fluxcd-operator
NAMESPACE=cozy-fluxcd

include ../../../scripts/package.mk

apply-locally:
	helm upgrade -i -n $(NAMESPACE) $(NAME) .

update:
	rm -rf charts
	helm pull oci://ghcr.io/controlplaneio-fluxcd/charts/flux-operator --untar --untardir charts
	patch --no-backup-if-mismatch -p1 < patches/kubernetesEnvs.diff
