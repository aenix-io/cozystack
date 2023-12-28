update:
	rm -rf charts && mkdir -p charts/kube-ovn
	tag=$$(git ls-remote --tags --sort="v:refname" https://github.com/kubeovn/kube-ovn  | awk -F'[/^]' 'END{print $$3}') && \
	curl -sSL https://github.com/kubeovn/kube-ovn/archive/refs/tags/$${tag}.tar.gz | \
	tar -C charts/kube-ovn -xzvf - --strip 2 kube-ovn-$${tag#*v}/charts
	sed -i 's/kube-system/cozy-kubeovn/g' `grep -lr kube-system charts | grep -v values.yaml`
	sed -i ./charts/kube-ovn/templates/*.yaml \
  	-e '/path:/ s|/etc/origin/|/var/lib/|' \
		-e '/mountPath:/ s|/usr/local/bin|/opt/bin|' 
		
