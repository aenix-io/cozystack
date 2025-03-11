export NAME=kubeovn-webhook
export NAMESPACE=cozy-kubeovn

include ../../../scripts/common-envs.mk
include ../../../scripts/package.mk

image:
	docker buildx build images/kubeovn-webhook \
		--provenance false \
		--tag $(REGISTRY)/kubeovn-webhook:$(call settag,$(TAG)) \
		--cache-from type=registry,ref=$(REGISTRY)/kubeovn-webhook:latest \
		--cache-to type=inline \
		--metadata-file images/kubeovn-webhook.json \
		--push=$(PUSH) \
		--label "org.opencontainers.image.source=https://github.com/cozystack/cozystack"
		--load=$(LOAD)
	IMAGE="$(REGISTRY)/kubeovn-webhook:$(call settag,$(TAG))@$$(yq e '."containerimage.digest"' images/kubeovn-webhook.json -o json -r)" \
		yq -i '.image = strenv(IMAGE)' values.yaml
	rm -f images/kubeovn-webhook.json
