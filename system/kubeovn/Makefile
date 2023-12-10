update:
	tag=$$(git ls-remote --tags --sort="v:refname" https://github.com/kubeovn/kube-ovn  | awk -F'[/^]' 'END{print $$3}') && \
	wget https://raw.githubusercontent.com/kubeovn/kube-ovn/$$tag/dist/images/install.sh -O install.sh
	sed -i '/path:/ s|/etc/origin/|/var/lib/|' install.sh
	sed -i '/mountPath:/ s|/usr/local/bin|/opt/bin|' install.sh
	patch -p1 < patches/talos.patch
	sed -i 's/kube-system/cozy-kubeovn/g' install.sh

apply:
	kubectl get ns cozy-kubeovn >/dev/null 2>&1 || kubectl create namespace cozy-kubeovn
	kubectl label namespace cozy-kubeovn pod-security.kubernetes.io/enforce=privileged --overwrite
	ENABLE_SSL=true ENABLE_LB=false ENABLE_NP=false bash install.sh

clean:
	rm -f *.yaml install.sh.orig
