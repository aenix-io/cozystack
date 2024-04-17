NAME=cilium
NAMESPACE=cozy-$(NAME)

include ../../hack/package-system.mk

update:
	rm -rf charts
	helm repo add $(NAME) https://helm.cilium.io/
	helm repo update $(NAME)
	helm pull $(NAME)/$(NAME) --untar --untardir charts --version 1.14
	sed -i -e '/Used in iptables/d' -e '/SYS_MODULE/d' charts/$(NAME)/values.yaml
	patch -p3 --no-backup-if-mismatch < patches/fix-cgroups.patch
