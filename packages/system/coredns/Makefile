export NAME=coredns
export NAMESPACE=cozy-$(NAME)


include ../../../scripts/package.mk

update:
	rm -rf charts
	helm repo add coredns https://coredns.github.io/helm
	helm repo update coredns
	helm pull coredns/coredns --untar --untardir charts
