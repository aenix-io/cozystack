OUT=../_out/apps

CURRENT_CHART_TARGETS=$(shell awk '/ HEAD$$/ {print $$3 "/" $$1 "/" $$2 }' versions_map)
HISTORICAL_CHARTS_TARGETS=$(shell awk '!/ HEAD$$/ {print $$3 "/" $$1 "/" $$2}' versions_map)

repo: repo-dir $(CURRENT_CHART_TARGETS) $(HISTORICAL_CHARTS_TARGETS)
	cd "$(OUT)" && helm repo index .

repo-dir:
	rm -rf "$(OUT)"
	mkdir -p "$(OUT)"

$(CURRENT_CHART_TARGETS):
	tar -czf- "$(word 2, $(subst /, ,$@))" > "$(OUT)/$(word 2, $(subst /, ,$@))-$(word 3, $(subst /, ,$@)).tgz"

$(HISTORICAL_CHARTS_TARGETS):
	git archive "$(word 1, $(subst /, ,$@))" "$(word 2, $(subst /, ,$@))" | gzip > "$(OUT)/$(word 2, $(subst /, ,$@))-$(word 3, $(subst /, ,$@)).tgz"

fix-chartnames:
	find . -name Chart.yaml -maxdepth 2 | awk -F/ '{print $$2}' | while read i; do sed -i "s/^name: .*/name: $$i/" "$$i/Chart.yaml"; done

gen-versions-map: fix-chartnames
	./gen_versions_map.sh

check-version-map: gen-versions-map
	git diff --exit-code -- versions_map
