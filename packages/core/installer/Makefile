NAMESPACE=cozy-installer
NAME=installer
PUSH := 1
LOAD := 0
REGISTRY := ghcr.io/aenix-io/cozystack
TAG := v0.0.1
TALOS_VERSION=$(shell awk '/^version:/ {print $$2}' images/talos/profiles/installer.yaml)

show:
	helm template -n $(NAMESPACE) $(NAME) .

apply:
	helm template -n $(NAMESPACE) $(NAME) . | kubectl apply -f -

diff:
	helm template -n $(NAMESPACE) $(NAME) . | kubectl diff -f -

update:
	hack/gen-profiles.sh

image: image-installer image-talos image-matchbox

image-installer:
	docker buildx build -f images/installer/Dockerfile ../../.. \
		--provenance false \
		--tag $(REGISTRY)/installer:$(TAG) \
		--cache-from type=registry,ref=$(REGISTRY)/installer:$(TAG) \
		--cache-to type=inline \
		--metadata-file images/installer.json \
		--push=$(PUSH) \
		--load=$(LOAD)
	echo "$(REGISTRY)/installer:$(TAG)" > images/installer.tag

image-talos:
	test -f ../../../_out/assets/installer-amd64.tar || make talos-installer
	docker load -i ../../../_out/assets/installer-amd64.tar
	docker tag ghcr.io/siderolabs/installer:$(TALOS_VERSION) ghcr.io/aenix-io/cozystack/talos:$(TALOS_VERSION)
	docker push ghcr.io/aenix-io/cozystack/talos:$(TALOS_VERSION)

image-matchbox:
	test -f ../../../_out/assets/kernel-amd64 || make talos-kernel
	test -f ../../../_out/assets/initramfs-metal-amd64.xz || make talos-initramfs
	docker buildx build -f images/matchbox/Dockerfile ../../.. \
		--provenance false \
		--tag $(REGISTRY)/matchbox:$(TAG) \
		--cache-from type=registry,ref=$(REGISTRY)/matchbox:$(TAG) \
		--cache-to type=inline \
		--metadata-file images/matchbox.json \
		--push=$(PUSH) \
		--load=$(LOAD)
	echo "$(REGISTRY)/matchbox:$(TAG)" > images/matchbox.tag

assets: talos-iso

talos-initramfs talos-kernel talos-installer talos-iso:
	cat images/talos/profiles/$(subst talos-,,$@).yaml | docker run --rm -i -v $${PWD}/../../../_out/assets:/out -v /dev:/dev --privileged "ghcr.io/siderolabs/imager:$(TALOS_VERSION)" -
