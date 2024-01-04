OUT=../_out/apps

repo:
	rm -rf "$(OUT)"
	mkdir -p "$(OUT)"
	cat versions_map | while read chart version commit; do git archive "$$commit" "$$chart" | gzip > "$(OUT)/$$chart-$$version.tgz"; done
	cd $(OUT) && helm repo index .

fix-chartnames:
	find . -name Chart.yaml -maxdepth 2 | awk -F/ '{print $$2}' | while read i; do sed -i "s/^name: .*/name: $$i/" "$$i/Chart.yaml"; done

gen-versions-map: fix-chartnames
	./gen_versions_map.sh

check-version-map: gen-versions-map
	git diff --exit-code -- versions_map
