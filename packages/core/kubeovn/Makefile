NAMESPACE=cozy-kubeovn
NAME=kubeovn

show:
	helm template --dry-run=server -n $(NAMESPACE) $(NAME) .

apply:
	kubectl label node -lnode-role.kubernetes.io/control-plane kube-ovn/role=master --overwrite && \
	MASTER_NODES=$$(kubectl get nodes -lkube-ovn/role=master -o jsonpath='{.items[*].status.addresses[?(@.type=="InternalIP")].address}' | tr ' ' ',') && \
	MASTER_COUNT=$$(echo "$$MASTER_NODES" | awk -F, '{ print NF }') && \
	set -x && \
	helm upgrade -i -n $(NAMESPACE) $(NAME) .

diff:
	helm diff upgrade --dry-run --allow-unreleased -n $(NAMESPACE) $(NAME) .

update:
	rm -rf charts && mkdir -p charts/kube-ovn
	curl -sSL https://github.com/kubeovn/kube-ovn/archive/refs/heads/master.tar.gz | \
	tar -C charts/kube-ovn -xzvf - --strip 2 kube-ovn-master/charts
	cd charts/kube-ovn && patch -p2 < ../../patches/talos.patch
