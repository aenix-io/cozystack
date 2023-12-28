update:
	rm -rf charts
	helm repo add cilium https://helm.cilium.io/
	helm repo update cilium
	helm pull cilium/cilium --untar --untardir charts
	sed -i -e '/Used in iptables/d' -e '/SYS_MODULE/d' charts/cilium/values.yaml
	patch -p3 < patches/fix-cgroups.patch
