NAMESPACE=cozy-kubeovn
NAME=kubeovn

show:
	helm template --dry-run=server -n $(NAMESPACE) $(NAME) .

apply:
	helm upgrade -i -n $(NAMESPACE) $(NAME) .

diff:
	helm diff upgrade --dry-run --allow-unreleased -n $(NAMESPACE) $(NAME) .

update:
	rm -rf charts && mkdir -p charts/kube-ovn
	curl -sSL https://github.com/kubeovn/kube-ovn/archive/refs/heads/master.tar.gz | \
	tar -C charts/kube-ovn -xzvf - --strip 2 kube-ovn-master/charts
	cd charts/kube-ovn && patch -p2 < ../../patches/talos.patch
	sed -i '/kube-ovn\/role.*master/ s|kube-ovn/role\(.*\)master|node-role.kubernetes.io/control-plane\1|g' $$(grep -rl 'kube-ovn/role' charts/kube-ovn/templates)
