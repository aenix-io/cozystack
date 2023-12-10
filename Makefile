.PHONY: manifests repos assets

manifests:
	(cd packages/core/installer/; helm template -n cozy-installer installer .) > manifests/cozystack-installer.yaml

repos:
	rm -rf _out
	make -C packages/apps check-version-map
	make -C packages/extra check-version-map
	make -C packages/system repo
	make -C packages/apps repo
	make -C packages/extra repo

assets:
	make -C packages/core/talos/ assets
