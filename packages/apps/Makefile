REPO=apps

repo:
	rm -rf ../repos/$(REPO)
	mkdir -p ../repos/$(REPO)
	cd ../repos/$(REPO) && helm package $$(find ../../$(REPO) -mindepth 2 -maxdepth 2 -name Chart.yaml | awk 'sub("/Chart.yaml", "")')
	cd ../repos/$(REPO) && helm repo index .

fix-chartnames:
	find . -name Chart.yaml -maxdepth 2 | awk -F/ '{print $$2}' | while read i; do sed -i "s/^name: .*/name: $$i/" "$$i/Chart.yaml"; done
