NAMESPACE=cozy-kubeovn
NAME=kubeovn

show:
	helm template --dry-run=server -n $(NAMESPACE) $(NAME) .

apply:
	helm upgrade -i -n $(NAMESPACE) $(NAME) .

diff:
	helm diff upgrade --allow-unreleased --normalize-manifests -n $(NAMESPACE) $(NAME) .

update:
	rm -rf charts && mkdir -p charts/kube-ovn
	curl -sSL https://github.com/kubeovn/kube-ovn/archive/refs/heads/master.tar.gz | \
	tar -C charts/kube-ovn -xzvf - --strip 2 kube-ovn-master/charts
	patch -p4 < patches/cozyconfig.diff
