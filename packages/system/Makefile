REPO=system

apply show diff:
	make -C cert-manager $@
	make -C cert-manager-issuers $@
	make -C victoria-metrics-operator $@
	make -C monitoring $@
	make -C kubevirt-operator $@
	make -C kubevirt $@
	make -C metallb $@
	make -C grafana-operator $@
	make -C mariadb-operator $@
	make -C postgres-operator $@
	make -C rabbitmq-operator $@
	make -C redis-operator $@
	make -C piraeus-operator $@
	make -C linstor $@
	make -C telepresence $@
	make -C ingress-nginx $@
	make -C kubeapps $@

repo: fix-chartnames
	rm -rf ../repos/$(REPO)
	mkdir -p ../repos/$(REPO)
	cd ../repos/$(REPO) && helm package $$(find ../../$(REPO) -mindepth 2 -maxdepth 2 -name Chart.yaml | awk 'sub("/Chart.yaml", "")')
	cd ../repos/$(REPO) && helm repo index .

fix-chartnames:
	find . -name Chart.yaml -maxdepth 2 | awk -F/ '{print $$2}' | while read i; do printf "name: cozy-%s\nversion: 1.0.0\n" "$$i" > "$$i/Chart.yaml"; done
