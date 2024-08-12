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

update:
	hack/gen-profiles.sh

image: image-cozystack image-talos image-matchbox

image-cozystack:
	make -C ../../.. repos
	docker buildx build -f images/cozystack/Dockerfile ../../.. \
		--provenance false \
		--tag $(REGISTRY)/cozystack:$(call settag,$(TAG)) \
		--cache-from type=registry,ref=$(REGISTRY)/cozystack:latest \
		--platform linux/amd64,linux/arm64 \
		--cache-to type=inline \
		--metadata-file images/cozystack.json \
		--push=$(PUSH) \
		--load=$(LOAD)
	IMAGE="$(REGISTRY)/cozystack:$(call settag,$(TAG))@$$(yq e '."containerimage.digest"' images/cozystack.json -o json -r)" \
		yq -i '.cozystack.image = strenv(IMAGE)' values.yaml
	rm -f images/cozystack.json

image-talos:
	test -f ../../../_out/assets/installer-amd64.tar || make talos-installer
	docker load -i ../../../_out/assets/installer-amd64.tar
	docker tag ghcr.io/siderolabs/installer:$(TALOS_VERSION) $(REGISTRY)/talos:$(call settag,$(TALOS_VERSION))
	docker push $(REGISTRY)/talos:$(call settag,$(TALOS_VERSION))

image-matchbox:
	test -f ../../../_out/assets/kernel-amd64 || make talos-kernel
	test -f ../../../_out/assets/initramfs-metal-amd64.xz || make talos-initramfs
	docker buildx build -f images/matchbox/Dockerfile ../../.. \
		--provenance false \
		--tag $(REGISTRY)/matchbox:$(call settag,$(TAG)) \
		--tag $(REGISTRY)/matchbox:$(call settag,$(TALOS_VERSION)-$(TAG)) \
		--cache-from type=registry,ref=$(REGISTRY)/matchbox:latest \
		--cache-to type=inline \
		--metadata-file images/matchbox.json \
		--push=$(PUSH) \
		--load=$(LOAD)
	rm -f images/matchbox.json

assets: talos-iso talos-nocloud

talos-initramfs talos-kernel talos-installer talos-iso talos-nocloud:
	mkdir -p ../../../_out/assets
	cat images/talos/profiles/$(subst talos-,,$@).yaml | \
		docker run --rm -i -v /dev:/dev --privileged "ghcr.io/siderolabs/imager:$(TALOS_VERSION)" --tar-to-stdout - | \
		tar -C ../../../_out/assets -xzf-
