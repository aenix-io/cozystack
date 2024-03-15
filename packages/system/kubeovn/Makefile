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
	tag=$$(git ls-remote --tags --sort="v:refname" https://github.com/kubeovn/kube-ovn  | awk -F'[/^]' 'END{print $$3}') && \
	curl -sSL https://github.com/kubeovn/kube-ovn/archive/refs/tags/$${tag}.tar.gz | \
	tar xzvf - --strip 1 kube-ovn-$${tag#*v}/charts
	patch -p4 < patches/cozyconfig.diff
