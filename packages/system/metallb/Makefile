NAME=metallb
NAMESPACE=cozy-$(NAME)

include ../../../hack/package-system.mk

update:
	rm -rf charts
	helm repo add metallb https://metallb.github.io/metallb
	helm repo update metallb
	helm pull metallb/metallb --untar --untardir charts
