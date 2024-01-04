OUT=../_out/system

gen: fix-chartnames

repo: fix-chartnames
	rm -rf "$(OUT)"
	mkdir -p "$(OUT)"
	helm package -d "$(OUT)" $$(find . -mindepth 2 -maxdepth 2 -name Chart.yaml | awk 'sub("/Chart.yaml", "")')
	cd "$(OUT)" && helm repo index .

fix-chartnames:
	find . -name Chart.yaml -maxdepth 2 | awk -F/ '{print $$2}' | while read i; do printf "name: cozy-%s\nversion: 1.0.0\n" "$$i" > "$$i/Chart.yaml"; done
