NAME=capi-operator
NAMESPACE=cozy-cluster-api

include ../../../scripts/package-system.mk

update:
	rm -rf charts
	helm repo add capi-operator https://kubernetes-sigs.github.io/cluster-api-operator
	helm repo update capi-operator
	helm pull capi-operator/cluster-api-operator --untar --untardir charts
	rm -rf charts/cluster-api-operator/charts
