KUBEOVN_TAG = v1.13.0

export NAME=kubeovn
export NAMESPACE=cozy-$(NAME)

include ../../../scripts/common-envs.mk
include ../../../scripts/package.mk

update:
	rm -rf charts && mkdir -p charts/kube-ovn
	curl -sSL https://github.com/kubeovn/kube-ovn/archive/refs/heads/master.tar.gz | \
	tar xzvf - --strip 1 kube-ovn-master/charts
	patch --no-backup-if-mismatch -p4 < patches/cozyconfig.diff

image:
	docker buildx build images/kubeovn \
		--provenance false \
		--tag $(REGISTRY)/kubeovn:$(call settag,$(KUBEOVN_TAG)) \
		--tag $(REGISTRY)/kubeovn:$(call settag,$(KUBEOVN_TAG)-$(TAG)) \
		--cache-from type=registry,ref=$(REGISTRY)/kubeovn:latest \
		--cache-to type=inline \
		--metadata-file images/kubeovn.json \
		--push=$(PUSH) \
		--load=$(LOAD)
	REGISTRY="$(REGISTRY)" \
		yq -i '.global.registry.address = strenv(REGISTRY)' values.yaml
	REPOSITORY="kubeovn" \
		yq -i '.global.images.kubeovn.repository = strenv(REPOSITORY)' values.yaml
	TAG="$(call settag,$(KUBEOVN_TAG))@$$(yq e '."containerimage.digest"' images/kubeovn.json -o json -r)" \
		yq -i '.global.images.kubeovn.tag = strenv(TAG)' values.yaml
	rm -f images/kubeovn.json
