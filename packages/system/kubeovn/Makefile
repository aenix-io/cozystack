KUBEOVN_TAG = v1.13.0

export NAME=kubeovn
export NAMESPACE=cozy-$(NAME)

include ../../../scripts/common-envs.mk
include ../../../scripts/package-system.mk

update:
	rm -rf charts && mkdir -p charts/kube-ovn
	curl -sSL https://github.com/kubeovn/kube-ovn/archive/refs/heads/master.tar.gz | \
	tar xzvf - --strip 1 kube-ovn-master/charts
	patch -p4 --no-backup-if-mismatch < patches/cozyconfig.diff
	ln -s ../../images charts/kube-ovn/images
	sed -i '/image:/ s/{{.*}}/{{ include "kubeovn.image" . }}/g' `grep -rl image: charts/kube-ovn/templates/`

image:
	docker buildx build images/kubeovn \
		--provenance false \
		--tag $(REGISTRY)/kubeovn:$(call settag,$(KUBEOVN_TAG)) \
		--tag $(REGISTRY)/kubeovn:$(call settag,$(KUBEOVN_TAG)-$(TAG)) \
		--cache-from type=registry,ref=$(REGISTRY)/kubeovn:latest \
		--cache-to type=inline \
		--metadata-file images/kubeovn.json \
		--push=$(PUSH) \
		--load=$(LOAD)
	echo "$(REGISTRY)/kubeovn:$(call settag,$(KUBEOVN_TAG))" > images/kubeovn.tag
