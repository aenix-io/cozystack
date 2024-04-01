NAMESPACE=cozy-kubeovn
NAME=kubeovn

show:
	kubectl get hr -n $(NAMESPACE) $(NAME) -o jsonpath='{.spec.values}' | helm template --dry-run=server -n $(NAMESPACE) $(NAME) . -f -

apply:
	kubectl get hr -n $(NAMESPACE) $(NAME) -o jsonpath='{.spec.values}' | helm upgrade -i -n $(NAMESPACE) $(NAME) . -f -

diff:
	kubectl get hr -n $(NAMESPACE) $(NAME) -o jsonpath='{.spec.values}' | helm diff upgrade --allow-unreleased --normalize-manifests -n $(NAMESPACE) $(NAME) . -f -

update:
	rm -rf charts && mkdir -p charts/kube-ovn
	curl -sSL https://github.com/kubeovn/kube-ovn/archive/refs/heads/master.tar.gz | \
	tar -C charts/kube-ovn -xzvf - --strip 2 kube-ovn-master/charts
