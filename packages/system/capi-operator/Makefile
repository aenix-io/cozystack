NAME=capi-operator
NAMESPACE=cozy-cluster-api
TYPE=system

include ../../../scripts/common-envs.mk
include ../../../scripts/package-system.mk

update: update-charts update-dockerfiles

update-charts:
	rm -rf charts
	helm repo add capi-operator https://kubernetes-sigs.github.io/cluster-api-operator
	helm repo update capi-operator
	helm pull capi-operator/cluster-api-operator --untar --untardir charts
	rm -rf charts/cluster-api-operator/charts

update-dockerfiles:
	../../../scripts/update-dockerfiles.sh with_helm

image:
	../../../scripts/build-images.sh $(REGISTRY) $(NAME) $(TYPE) $(PUSH) $(LOAD)
