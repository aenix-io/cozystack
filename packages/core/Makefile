REPO=core

apply show diff:
	make -C namespaces $@
	make -C cilium $@
	make -C kubeovn $@
	make -C fluxcd $@

repo: fix-chartnames
	rm -rf ../repos/$(REPO)
	mkdir -p ../repos/$(REPO)
	cd ../repos/$(REPO) && helm package $$(find ../../$(REPO) -mindepth 2 -maxdepth 2 -name Chart.yaml | awk 'sub("/Chart.yaml", "")')
	cd ../repos/$(REPO) && helm repo index .

fix-chartnames:
	find . -name Chart.yaml -maxdepth 2 | awk -F/ '{print $$2}' | while read i; do printf "name: cozy-%s\nversion: 1.0.0\n" "$$i" > "$$i/Chart.yaml"; done
