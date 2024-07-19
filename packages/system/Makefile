OUT=../../_out/repos/system

include ../../scripts/common-envs.mk

repo:
	rm -rf "$(OUT)"
	mkdir -p "$(OUT)"
	helm package -d "$(OUT)" $$(find . -mindepth 2 -maxdepth 2 -name Chart.yaml | awk 'sub("/Chart.yaml", "")') --version $(VERSION)
	cd "$(OUT)" && helm repo index .

fix-chartnames:
	find . -maxdepth 2 -name Chart.yaml | awk -F/ '{print $$2}' | while read i; do sed -i "s/^name: .*/name: cozy-$$i/" "$$i/Chart.yaml"; done
