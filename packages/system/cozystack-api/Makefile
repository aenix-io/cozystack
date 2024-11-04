NAME=installer
NAMESPACE=cozy-system

TALOS_VERSION=$(shell awk '/^version:/ {print $$2}' images/talos/profiles/installer.yaml)

include ../../../scripts/common-envs.mk

show:
	helm template -n $(NAMESPACE) $(NAME) .

apply:
	helm template -n $(NAMESPACE) $(NAME) . | kubectl apply -f -

diff:
	helm template -n $(NAMESPACE) $(NAME) . | kubectl diff -f -

image: image-cozystack-api

image-cozystack-api:
	docker buildx build -f images/cozystack-api/Dockerfile ../../.. \
		--provenance false \
		--tag $(REGISTRY)/cozystack-api:$(call settag,$(TAG)) \
		--cache-from type=registry,ref=$(REGISTRY)/cozystack-api:latest \
		--cache-to type=inline \
		--metadata-file images/cozystack-api.json \
		--push=$(PUSH) \
		--load=$(LOAD)
	IMAGE="$(REGISTRY)/cozystack-api:$(call settag,$(TAG))@$$(yq e '."containerimage.digest"' images/cozystack-api.json -o json -r)" \
		yq -i '.cozystackAPI.image = strenv(IMAGE)' values.yaml
	#rm -f images/cozystack-api.json
