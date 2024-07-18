export NAME=nats-operator
export NAMESPACE=cozy-$(NAME)

include ../../../scripts/package-system.mk

update:
	rm -rf charts
	helm repo add nats https://nats-io.github.io/k8s/helm/charts/
	helm repo update nats
	helm pull nats/nats-operator --untar --untardir charts
