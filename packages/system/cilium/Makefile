NAMESPACE=cozy-cilium
NAME=cilium

show:
	helm template --dry-run=server -n $(NAMESPACE) $(NAME) .

apply:
	helm upgrade -i -n $(NAMESPACE) $(NAME) .

diff:
	helm diff upgrade --allow-unreleased --normalize-manifests -n $(NAMESPACE) $(NAME) .

update:
	rm -rf charts
	helm repo add cilium https://helm.cilium.io/
	helm repo update cilium
	helm pull cilium/cilium --untar --untardir charts
	sed -i -e '/Used in iptables/d' -e '/SYS_MODULE/d' charts/cilium/values.yaml
	patch -p3 < patches/fix-cgroups.patch
