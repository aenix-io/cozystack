export NAME=dashboard
export NAMESPACE=cozy-$(NAME)

include ../../../scripts/common-envs.mk
include ../../../scripts/package-system.mk

update: update-chart update-dockerfiles
image: image-dashboard image-kubeapps-apis

update-chart:
	rm -rf charts
	helm repo add bitnami https://charts.bitnami.com/bitnami
	helm repo update bitnami
	helm pull bitnami/kubeapps --untar --untardir charts
	rm -rf charts/kubeapps/charts/postgresql/
	ln -s ../../images charts/kubeapps/images
	sed -i 's/.cluster.local//g' charts/kubeapps/templates/kubeappsapis/deployment.yaml
	patch --no-backup-if-mismatch charts/kubeapps/templates/frontend/configmap.yaml < patches/logos.patch

update-dockerfiles:
	tag=$$(git ls-remote --tags --sort="v:refname" https://github.com/vmware-tanzu/kubeapps  | awk -F'[/^]' 'END{print $$3}') && \
	wget https://github.com/vmware-tanzu/kubeapps/raw/$${tag}/cmd/kubeapps-apis/Dockerfile -O images/kubeapps-apis/Dockerfile && \
	patch --no-backup-if-mismatch images/kubeapps-apis/Dockerfile < images/kubeapps-apis/dockerfile.diff && \
	node_image=$$(wget -O- https://github.com/vmware-tanzu/kubeapps/raw/main/dashboard/Dockerfile | awk '/FROM bitnami\/node/ {print $$2}') && \
	sed -i "s|FROM .* AS build|FROM $${node_image} AS build|" images/dashboard/Dockerfile && \
	version=$$(echo "$$tag" | sed 's/^v//') && \
	sed -i "s/ARG VERSION=.*/ARG VERSION=$${version}/" images/dashboard/Dockerfile

image-dashboard:
	docker buildx build images/dashboard \
		--provenance false \
		--tag $(REGISTRY)/dashboard:$(call settag,$(TAG)) \
		--cache-from type=registry,ref=$(REGISTRY)/dashboard:latest \
		--cache-to type=inline \
		--metadata-file images/dashboard.json \
		--push=$(PUSH) \
		--load=$(LOAD)
	echo "$(REGISTRY)/dashboard:$(call settag,$(TAG))" > images/dashboard.tag

image-kubeapps-apis:
	docker buildx build images/kubeapps-apis \
		--provenance false \
		--tag $(REGISTRY)/kubeapps-apis:$(call settag,$(TAG)) \
		--cache-from type=registry,ref=$(REGISTRY)/kubeapps-apis:latest \
		--cache-to type=inline \
		--metadata-file images/kubeapps-apis.json \
		--push=$(PUSH) \
		--load=$(LOAD)
	echo "$(REGISTRY)/kubeapps-apis:$(call settag,$(TAG))" > images/kubeapps-apis.tag
