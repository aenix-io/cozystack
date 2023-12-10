NAME=kubevirt
NAMESPACE=cozy-kubevirt

show:
	helm template --dry-run=server -n $(NAMESPACE) $(NAME) .

apply:
	helm upgrade -i -n $(NAMESPACE) $(NAME) .

diff:
	helm diff upgrade --allow-unreleased --normalize-manifests -n $(NAMESPACE) $(NAME) .

update:
	rm -rf templates
	mkdir templates
	export RELEASE=$$(curl https://storage.googleapis.com/kubevirt-prow/release/kubevirt/kubevirt/stable.txt) && \
	wget https://github.com/kubevirt/kubevirt/releases/download/$${RELEASE}/kubevirt-cr.yaml -O templates/kubevirt-cr.yaml
	sed -i 's/namespace: kubevirt/namespace: cozy-kubevirt/g' templates/kubevirt-cr.yaml
