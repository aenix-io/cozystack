NAME=postgres-operator
NAMESPACE=cozy-$(NAME)

include ../../../hack/package-system.mk

update:
	rm -rf charts
	helm repo add cnpg https://cloudnative-pg.github.io/charts
	helm repo update cnpg
	helm pull cnpg/cloudnative-pg --untar --untardir charts
