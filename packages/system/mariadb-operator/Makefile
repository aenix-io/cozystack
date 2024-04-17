NAME=mariadb-operator
NAMESPACE=cozy-$(NAME)

include ../../../hack/package-system.mk

update:
	rm -rf charts
	helm repo add mariadb-operator https://mariadb-operator.github.io/mariadb-operator
	helm repo update mariadb-operator
	helm pull mariadb-operator/mariadb-operator --untar --untardir charts
