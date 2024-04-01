NAMESPACE=cozy-cilium
NAME=cilium

show:
	kubectl get hr -n cozy-cilium cilium -o jsonpath='{.spec.values}' | helm template --dry-run=server -n $(NAMESPACE) $(NAME) . -f -

apply:
	kubectl get hr -n cozy-cilium cilium -o jsonpath='{.spec.values}' | helm upgrade -i -n $(NAMESPACE) $(NAME) . -f -

diff:
	kubectl get hr -n cozy-cilium cilium -o jsonpath='{.spec.values}' | helm diff upgrade --allow-unreleased --normalize-manifests -n $(NAMESPACE) $(NAME) . -f -

update:
	rm -rf charts
	helm repo add cilium https://helm.cilium.io/
	helm repo update cilium
	helm pull cilium/cilium --untar --untardir charts
	sed -i -e '/Used in iptables/d' -e '/SYS_MODULE/d' charts/cilium/values.yaml
	patch -p3 --no-backup-if-mismatch < patches/fix-cgroups.patch
