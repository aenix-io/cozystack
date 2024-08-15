export NAME=kamaji
export NAMESPACE=cozy-$(NAME)

include ../../../scripts/common-envs.mk
include ../../../scripts/package.mk

update:
	rm -rf charts
	helm repo add clastix https://clastix.github.io/charts
	helm repo update clastix
	helm pull clastix/kamaji --untar --untardir charts

image:
	docker buildx build images/kamaji \
		--provenance false \
		--tag $(REGISTRY)/kamaji:$(call settag,$(TAG)) \
		--cache-from type=registry,ref=$(REGISTRY)/kamaji:latest \
		--cache-to type=inline \
		--metadata-file images/kamaji.json \
		--push=$(PUSH) \
		--label "org.opencontainers.image.source=https://github.com/aenix-io/cozystack"
		--load=$(LOAD)
	REPOSITORY="$(REGISTRY)/kamaji" \
		yq -i '.kamaji.image.repository = strenv(REPOSITORY)' values.yaml
	TAG=$(TAG)@$$(yq e '."containerimage.digest"' images/kamaji.json -o json -r) \
		yq -i '.kamaji.image.tag = strenv(TAG)' values.yaml
	rm -f images/kamaji.json
