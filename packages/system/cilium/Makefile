CILIUM_TAG=$(shell awk '$$1 == "version:" {print $$2}' charts/cilium/Chart.yaml)

NAME=cilium
NAMESPACE=cozy-$(NAME)

include ../../../scripts/common-envs.mk
include ../../../scripts/package-system.mk

update:
	rm -rf charts
	helm repo add cilium https://helm.cilium.io/
	helm repo update cilium
	helm pull cilium/cilium --untar --untardir charts --version 1.15
	ln -s ../../images charts/cilium/images
	sed -i 's/include "cilium.image" .Values.image/include "cilium.image" ./g' charts/cilium/templates/cilium-agent/daemonset.yaml
	sed -i -e '/Used in iptables/d' -e '/SYS_MODULE/d' charts/cilium/values.yaml
	version=$$(awk '$$1 == "version:" {print $$2}' charts/cilium/Chart.yaml) && \
	sed -i "s/ARG VERSION=.*/ARG VERSION=v$${version}/" images/cilium/Dockerfile

image:
	docker buildx build images/cilium \
		--provenance false \
		--tag $(REGISTRY)/cilium:$(call settag,$(CILIUM_TAG)) \
		--tag $(REGISTRY)/cilium:$(call settag,$(CILIUM_TAG)-$(TAG)) \
		--cache-from type=registry,ref=$(REGISTRY)/cilium:latest \
		--cache-to type=inline \
		--metadata-file images/cilium.json \
		--push=$(PUSH) \
		--load=$(LOAD)
	echo "$(REGISTRY)/cilium:$(call settag,$(CILIUM_TAG))" > images/cilium.tag
