.PHONY: manifests

manifests:
	(cd packages/core/installer/; helm template -n cozy-installer installer .) > manifests/cozystack-installer.yaml
