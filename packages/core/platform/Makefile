NAMESPACE=cozy-system
NAME=fluxcd-releases

show:
	helm template -n $(NAMESPACE) $(NAME) .

apply:
	helm template -n $(NAMESPACE) $(NAME) . --dry-run=server | kubectl apply -f-

namespaces-show:
	helm template -n $(NAMESPACE) $(NAME) . -s templates/namespaces.yaml

namespaces-apply:
	helm template -n $(NAMESPACE) $(NAME) . -s templates/namespaces.yaml | kubectl apply -f-

diff:
	helm diff upgrade --allow-unreleased -n $(NAMESPACE) $(NAME) .

update:
	rm -rf charts
	helm repo add cilium https://helm.cilium.io/
	helm repo update cilium
	helm pull cilium/cilium --untar --untardir charts
	sed -i -e '/Used in iptables/d' -e '/SYS_MODULE/d' charts/cilium/values.yaml
	patch -p3 < patches/fix-cgroups.patch
