NAME=kubevirt-operator
NAMESPACE=cozy-kubevirt

include ../../hack/package-system.mk

update:
	rm -rf templates
	mkdir templates
	export RELEASE=$$(curl https://storage.googleapis.com/kubevirt-prow/release/kubevirt/kubevirt/stable.txt) && \
	wget https://github.com/kubevirt/kubevirt/releases/download/$${RELEASE}/$(NAME).yaml -O templates/$(NAME).yaml && \
	sed -i 's/namespace: kubevirt/namespace: $(NAMESPACE)/g' templates/$(NAME).yaml
	awk -i inplace -v RS="---" '!/kind: Namespace/{printf "%s", $$0 RS}' templates/$(NAME).yaml
