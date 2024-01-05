OUT=../_out/apps
TMP=../_out/apps/historical

repo: historical-charts
	rm -rf "$(OUT)"
	mkdir -p "$(OUT)"
	while read chart version commit; do \
		mkdir -p $(TMP)/$$chart-$$version && \
		git archive $$commit $$chart | tar --strip-components=1 -C $(TMP)/$$chart-$$version -xf-; \
	done < versions_map
	helm package -d "$(OUT)" $$(find . $(TMP) -mindepth 2 -maxdepth 2 -name Chart.yaml | awk 'sub("/Chart.yaml", "")' | sort -V)
	cd "$(OUT)" && helm repo index .
	rm -rf "$(TMP)"

historical-charts:

fix-chartnames:
	find . -name Chart.yaml -maxdepth 2 | awk -F/ '{print $$2}' | while read i; do sed -i "s/^name: .*/name: $$i/" "$$i/Chart.yaml"; done

gen-versions-map: fix-chartnames
	./gen_versions_map.sh

check-version-map: gen-versions-map
	git diff --exit-code -- versions_map
