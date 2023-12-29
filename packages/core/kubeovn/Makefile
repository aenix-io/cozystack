NAMESPACE=cozy-kubeovn
NAME=kubeovn

show:
	helm template -n $(NAMESPACE) $(NAME) .

apply:
	kubectl label node -lnode-role.kubernetes.io/control-plane kube-ovn/role=master --overwrite && \
	MASTER_NODES=$$(kubectl get nodes -lkube-ovn/role=master -o jsonpath='{.items[*].status.addresses[?(@.type=="InternalIP")].address}' | tr ' ' ',') && \
	MASTER_COUNT=$$(echo "$$MASTER_NODES" | awk -F, '{ print NF }') && \
	set -x && \
	helm upgrade -i -n $(NAMESPACE) $(NAME) . -f values-runtime.yaml

diff:
	helm diff upgrade --allow-unreleased -n $(NAMESPACE) $(NAME) .

update:
	rm -rf charts && mkdir -p charts/kube-ovn
	tag=$$(git ls-remote --tags --sort="v:refname" https://github.com/kubeovn/kube-ovn  | awk -F'[/^]' 'END{print $$3}') && \
	curl -sSL https://github.com/kubeovn/kube-ovn/archive/refs/tags/$${tag}.tar.gz | \
	tar -C charts/kube-ovn -xzvf - --strip 2 kube-ovn-$${tag#*v}/charts
	sed -i 's/kube-system/cozy-kubeovn/g' `grep -lr kube-system charts | grep -v values.yaml`
	sed -i ./charts/kube-ovn/templates/*.yaml \
  	-e '/path:/ s|/etc/origin/|/var/lib/|' \
		-e '/mountPath:/ s|/usr/local/bin|/opt/bin|' 
