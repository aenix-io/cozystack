PUSH := 1
LOAD := 0
REGISTRY := ghcr.io/aenix-io/cozystack
TAG := v0.3.0
UBUNTU_CONTAINER_DISK_TAG = v1.29.1

image: image-ubuntu-container-disk

image-ubuntu-container-disk:
	docker buildx build --platform linux/amd64 --build-arg ARCH=amd64 images/ubuntu-container-disk \
		--provenance false \
		--tag $(REGISTRY)/ubuntu-container-disk:$(UBUNTU_CONTAINER_DISK_TAG) \
		--tag $(REGISTRY)/ubuntu-container-disk:$(UBUNTU_CONTAINER_DISK_TAG)-$(TAG) \
		--cache-from type=registry,ref=$(REGISTRY)/ubuntu-container-disk:$(UBUNTU_CONTAINER_DISK_TAG) \
		--cache-to type=inline \
		--metadata-file images/ubuntu-container-disk.json \
		--push=$(PUSH) \
		--load=$(LOAD)
	echo "$(REGISTRY)/ubuntu-container-disk:$(UBUNTU_CONTAINER_DISK_TAG)" > images/ubuntu-container-disk.tag
