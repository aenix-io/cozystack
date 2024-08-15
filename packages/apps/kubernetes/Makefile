UBUNTU_CONTAINER_DISK_TAG = v1.30.1

include ../../../scripts/common-envs.mk
include ../../../scripts/package.mk

generate:
	readme-generator -v values.yaml -s values.schema.json -r README.md

image: image-ubuntu-container-disk

image-ubuntu-container-disk:
	docker buildx build --platform linux/amd64 --build-arg ARCH=amd64 images/ubuntu-container-disk \
		--provenance false \
		--tag $(REGISTRY)/ubuntu-container-disk:$(call settag,$(UBUNTU_CONTAINER_DISK_TAG)) \
		--tag $(REGISTRY)/ubuntu-container-disk:$(call settag,$(UBUNTU_CONTAINER_DISK_TAG)-$(TAG)) \
		--cache-from type=registry,ref=$(REGISTRY)/ubuntu-container-disk:latest \
		--cache-to type=inline \
		--metadata-file images/ubuntu-container-disk.json \
		--push=$(PUSH) \
		--load=$(LOAD)
	echo "$(REGISTRY)/ubuntu-container-disk:$(call settag,$(UBUNTU_CONTAINER_DISK_TAG))@$$(yq e '."containerimage.digest"' images/ubuntu-container-disk.json -o json -r)" \
		> images/ubuntu-container-disk.tag
	rm -f images/ubuntu-container-disk.json
