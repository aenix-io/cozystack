NAME=kafka-operator
NAMESPACE=cozy-$(NAME)

include ../../../hack/package-system.mk

update:
	rm -rf charts
	helm pull oci://quay.io/strimzi-helm/strimzi-kafka-operator --untar --untardir charts
