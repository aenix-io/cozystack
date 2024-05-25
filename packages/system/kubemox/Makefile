NAME=kubemox
NAMESPACE=cozy-$(NAME)

include ../../../scripts/package-system.mk

update:
	rm -rf templates
	mkdir templates
	export RELEASE=v0.0.6-rc2 && \
	wget https://github.com/kubevirt/kubevirt/releases/download/$${RELEASE}/kubevirt-cr.yaml -O templates/kubevirt-cr.yaml
	sed -i 's/namespace: kubevirt/namespace: cozy-kubevirt/g' templates/kubevirt-cr.yaml
