NAME=kubeapps
NAMESPACE=cozy-kubeapps

show:
	helm template -n $(NAMESPACE) $(NAME) .

apply:
	helm upgrade -i -n $(NAMESPACE) $(NAME) .

diff:
	helm diff upgrade --allow-unreleased -n $(NAMESPACE) $(NAME) .

update: update-chart update-dockerfiles
image: image-dashboard image-kubeapps-apis

update-chart:
	rm -rf charts
	helm repo add bitnami https://charts.bitnami.com/bitnami
	helm repo update bitnami
	helm pull bitnami/kubeapps --untar --untardir charts
	rm -rf charts/kubeapps/charts/postgresql/
	sed -i 's|{{ include "kubeapps.dashboard.image" . }}|ghcr.io/aenix-io/cozystack/dashboard:latest|g' charts/kubeapps/templates/dashboard/deployment.yaml
	sed -i 's|{{ include "kubeapps.kubeappsapis.image" . }}|ghcr.io/aenix-io/cozystack/kubeapps-apis:latest|g' charts/kubeapps/templates/kubeappsapis/deployment.yaml

update-dockerfiles:
	tag=$$(git ls-remote --tags --sort="v:refname" https://github.com/vmware-tanzu/kubeapps  | awk -F'[/^]' 'END{print $$3}') && \
	wget https://github.com/vmware-tanzu/kubeapps/raw/$${tag}/cmd/kubeapps-apis/Dockerfile -O images/kubeapps-apis/Dockerfile && \
	patch images/kubeapps-apis/Dockerfile < images/kubeapps-apis/dockerfile.diff && \
	node_image=$$(wget -O- https://github.com/vmware-tanzu/kubeapps/raw/main/dashboard/Dockerfile | awk '/FROM bitnami\/node/ {print $$2}') && \
	sed -i "s|FROM .* AS build|FROM $${node_image} AS build|" images/dashboard/Dockerfile && \
	version=$$(echo "$$tag" | sed 's/^v//') && \
	sed -i "s/ARG VERSION=.*/ARG VERSION=$${version}/" images/dashboard/Dockerfile


image-dashboard:
	docker buildx build images/dashboard \
		--provenance false \
		--tag ghcr.io/aenix-io/cozystack/dashboard:latest \
		--cache-from type=registry,ref=ghcr.io/aenix-io/cozystack/dashboard:latest \
		--cache-to type=inline \
		--metadata-file images/dashboard.json \
		--push=$(PUSH) \
		--load=$(LOAD)

image-kubeapps-apis:
	docker buildx build images/kubeapps-apis \
		--provenance false \
		--tag ghcr.io/aenix-io/cozystack/kubeapps-apis:latest \
		--cache-from type=registry,ref=ghcr.io/aenix-io/cozystack/kubeapps-apis:latest \
		--cache-to type=inline \
		--metadata-file images/kubeapps-apis.json \
		--push=$(PUSH) \
		--load=$(LOAD)
