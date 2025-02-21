export NAME=keycloak-operator
export NAMESPACE=cozy-keycloak

include ../../../scripts/common-envs.mk
include ../../../scripts/package.mk

update:
	rm -rf charts
	helm repo add epamedp https://epam.github.io/edp-helm-charts/stable
	helm repo update epamedp
	helm pull epamedp/keycloak-operator --untar --untardir charts
