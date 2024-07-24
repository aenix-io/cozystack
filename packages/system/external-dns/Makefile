export NAME=external-dns
export NAMESPACE=cozy-$(NAME)

include ../../../scripts/package-system.mk

update:
	rm -rf charts
	helm repo add bitnami https://charts.bitnami.com/bitnami
	helm repo update bitnami
	helm pull bitnami/external-dns --untar --untardir charts