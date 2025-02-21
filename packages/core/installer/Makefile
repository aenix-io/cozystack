NAME=installer
NAMESPACE=cozy-system

TALOS_VERSION=$(shell awk '/^version:/ {print $$2}' images/talos/profiles/installer.yaml)

include ../../../scripts/common-envs.mk

pre-checks:
	../../../hack/pre-checks.sh

show:
	helm template -n $(NAMESPACE) $(NAME) .

apply:
	helm template -n $(NAMESPACE) $(NAME) . | kubectl apply -f -

diff:
	helm template -n $(NAMESPACE) $(NAME) . | kubectl diff -f -

update:
	hack/gen-profiles.sh
	IMAGE=$$(yq '.input.baseInstaller.imageRef | sub("/installer:", "/imager:")' images/talos/profiles/installer.yaml) \
		yq -i '.talos.imager.image = strenv(IMAGE)' ../builder/values.yaml

image: pre-checks image-cozystack image-talos image-matchbox

image-cozystack: run-builder
	make -C ../../.. repos
	docker buildx build -f images/cozystack/Dockerfile ../../.. \
		--provenance false \
		--tag $(REGISTRY)/cozystack:$(call settag,$(TAG)) \
		--cache-from type=registry,ref=$(REGISTRY)/cozystack:latest \
		--platform linux/amd64 \
		--cache-to type=inline \
		--metadata-file images/cozystack.json \
		--push=$(PUSH) \
		--load=$(LOAD)
	IMAGE="$(REGISTRY)/cozystack:$(call settag,$(TAG))@$$(yq e '."containerimage.digest"' images/cozystack.json -o json -r)" \
		yq -i '.cozystack.image = strenv(IMAGE)' values.yaml
	rm -f images/cozystack.json

image-talos: run-builder
	test -f ../../../_out/assets/installer-amd64.tar || make talos-installer
	skopeo copy docker-archive:../../../_out/assets/installer-amd64.tar docker://$(REGISTRY)/talos:$(call settag,$(TALOS_VERSION))

image-matchbox: run-builder
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
	echo "$(REGISTRY)/matchbox:$(call settag,$(TAG))@$$(yq e '."containerimage.digest"' images/matchbox.json -o json -r)" \
		> ../../extra/bootbox/images/matchbox.tag
	rm -f images/matchbox.json

assets: talos-iso talos-nocloud talos-metal

talos-initramfs talos-kernel talos-installer talos-iso talos-nocloud talos-metal:
	mkdir -p ../../../_out/assets
	cat images/talos/profiles/$(subst talos-,,$@).yaml | \
		kubectl exec -i -n cozy-builder deploy/builder-talos-imager -- imager --tar-to-stdout - | \
		tar -C ../../../_out/assets -xzf-

run-builder:
	make -C ../builder/ apply wait-for-builder
