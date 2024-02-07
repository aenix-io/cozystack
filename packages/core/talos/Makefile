TALOS_VERSION=$(shell awk '/^version:/ {print $$2}' profiles/installer.yaml)

gen-profiles:
	hack/gen-profiles.sh

assets: kernel initramfs iso

initramfs kernel installer iso:
	cat profiles/$@.yaml | docker run --rm -i -v $${PWD}/../../../_out/images:/out -v /dev:/dev --privileged "ghcr.io/siderolabs/imager:$(TALOS_VERSION)" -

image:
	test -f ../../../_out/images/installer-amd64.tar || make installer
	docker load -i ../../../_out/images/installer-amd64.tar
	docker tag ghcr.io/siderolabs/installer:$(TALOS_VERSION) ghcr.io/aenix-io/cozystack/talos:$(TALOS_VERSION)
	docker push ghcr.io/aenix-io/cozystack/talos:$(TALOS_VERSION)
