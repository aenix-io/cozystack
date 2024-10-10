.PHONY: manifests repos assets

build:
	make -C packages/apps/http-cache image
	make -C packages/apps/postgres image
	make -C packages/apps/mysql image
	make -C packages/apps/clickhouse image
	make -C packages/apps/kubernetes image
	make -C packages/system/cilium image
	make -C packages/system/kubeovn image
	make -C packages/system/dashboard image
	make -C packages/system/kamaji image
	make -C packages/system/bucket image
	make -C packages/core/testing image
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
	mkdir -p _out/logos
	cp ./packages/apps/*/logos/*.svg ./packages/extra/*/logos/*.svg _out/logos/

assets:
	make -C packages/core/installer/ assets

test:
	make -C packages/core/testing apply
	make -C packages/core/testing test
	make -C packages/core/testing delete
