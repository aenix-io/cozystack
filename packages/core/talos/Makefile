include versions.env

gen-versions:
	hack/gen-versions.sh | tee versions.env

image:
	docker run --rm \
		-v $${PWD}/../../../_out/images:/out -v /dev:/dev --privileged "ghcr.io/siderolabs/imager:$(TALOS_VERSION)" \
		--system-extension-image=ghcr.io/siderolabs/amd-ucode:$(AMD_UCODE_VERSION) \
		--system-extension-image=ghcr.io/siderolabs/amdgpu-firmware:$(AMDGPU_FIRMWARE_VERSION) \
		--system-extension-image=ghcr.io/siderolabs/bnx2-bnx2x:$(BNX2_BNX2X_VERSION) \
		--system-extension-image=ghcr.io/siderolabs/i915-ucode:$(I915_UCODE_VERSION) \
		--system-extension-image=ghcr.io/siderolabs/intel-ice-firmware:$(INTEL_ICE_FIRMWARE_VERSION) \
		--system-extension-image=ghcr.io/siderolabs/intel-ucode:$(INTEL_UCODE_VERSION) \
		--system-extension-image=ghcr.io/siderolabs/qlogic-firmware:$(QLOGIC_FIRMWARE_VERSION) \
		--system-extension-image=ghcr.io/siderolabs/drbd:$(DRBD_VERSION) \
		--system-extension-image=ghcr.io/siderolabs/zfs:$(ZFS_VERSION) \
		installer
