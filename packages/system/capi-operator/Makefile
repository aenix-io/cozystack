NAME=capi-operator
NAMESPACE=cozy-cluster-api
TYPE=system

include ../../../scripts/common-envs.mk
include ../../../scripts/package-system.mk

update: update-charts update-dockerfiles update-images

update-charts:
	rm -rf charts
	helm repo add capi-operator https://kubernetes-sigs.github.io/cluster-api-operator
	helm repo update capi-operator
	helm pull capi-operator/cluster-api-operator --untar --untardir charts
	rm -rf charts/cluster-api-operator/charts

update-dockerfiles:
	../../../hack/update-dockerfiles.sh with_helm

components := $(subst /,,$(subst images/,,$(dir $(wildcard images/*/Dockerfile))))
img_targets := $(addprefix image-,$(components))

update-images: $(img_targets)

.PHONY: $(img_targets)
$(img_targets):
	@$(eval name := $(subst image-,,$@))
	@$(eval tag := $(shell egrep -o "FROM .*$(name).*" images/$(name)/Dockerfile | awk -F: '{print $$NF}'))
	BUILDX_METADATA_PROVENANCE=0 docker buildx build images/$(name)/ \
		--provenance false \
		--tag $(subst //,/,$(REGISTRY)/$(TYPE)/$(name):$(tag)) \
		--cache-from type=registry,ref=$(subst //,/,$(REGISTRY)/$(TYPE)/$(name):latest) \
		--cache-to type=inline \
		--metadata-file images/$(name).json \
		--push=$(PUSH) \
		--load=$(LOAD) && \
	img_name=$$(jq -r '."image.name" | split(":")[:-1] | join(":")' images/$(name).json) \
		yq -i '.$(name).image.manager.repository = ("$${img_name}"|envsubst(nu,ne))' values.yaml && \
	img_tag=$$(jq -r '."image.name" | split(":")[-1]' images/$(name).json) \
	img_digest=$$(jq -r '."containerimage.digest"' images/$(name).json) \
		yq -i '.$(name).image.manager.tag = ("$${img_tag}@$${img_digest}"|envsubst(nu,ne))' values.yaml

