OUT=../_out/apps
TMP=../_out/apps/historical

repo:
	rm -rf "$(OUT)"
	mkdir -p "$(OUT)"
	awk '$$3 != "HEAD" {print "mkdir -p $(TMP)/" $$1 "-" $$2}' versions_map | sh -ex
	awk '$$3 != "HEAD" {print "git archive " $$3 " " $$1 " | tar -xf- --strip-components=1 -C $(TMP)/" $$1 "-" $$2 }' versions_map | sh -ex
	helm package -d "$(OUT)" $$(find . $(TMP) -mindepth 2 -maxdepth 2 -name Chart.yaml | awk 'sub("/Chart.yaml", "")' | sort -V)
	cd "$(OUT)" && helm repo index .
	rm -rf "$(TMP)"

fix-chartnames:
	find . -name Chart.yaml -maxdepth 2 | awk -F/ '{print $$2}' | while read i; do sed -i "s/^name: .*/name: $$i/" "$$i/Chart.yaml"; done

gen-versions-map: fix-chartnames
	./gen_versions_map.sh

check-version-map: gen-versions-map
	git diff --exit-code -- versions_map


aaa:
	$(shell awk 'BEGIN{printf "mkdir -p"} $$3 != "HEAD" {printf " $(OUT)" $$1 "-" $$2}' versions_map)
