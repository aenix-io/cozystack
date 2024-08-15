export NAME=metallb
export NAMESPACE=cozy-$(NAME)

include ../../../scripts/package.mk

update:
	rm -rf charts
	helm repo add metallb https://metallb.github.io/metallb
	helm repo update metallb
	helm pull metallb/metallb --untar --untardir charts
