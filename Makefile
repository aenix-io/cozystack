.PHONY: manifests repos assets

build:
	make -C packages/apps/http-cache image
	make -C packages/apps/kubernetes image
	make -C packages/system/kubeovn image
	make -C packages/system/dashboard image
	make -C packages/core/installer image
	make manifests

manifests:
	(cd packages/core/installer/; helm template -n cozy-installer installer .) > manifests/cozystack-installer.yaml
	sed -i 's|@sha256:[^"]\+||' manifests/cozystack-installer.yaml

repos:
	rm -rf _out
	make -C packages/apps check-version-map
	make -C packages/extra check-version-map
	make -C packages/system repo
	make -C packages/apps repo
	make -C packages/extra repo

assets:
	make -C packages/core/installer/ assets
