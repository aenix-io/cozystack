include ../../hack/app-helm.mk

update:
	#rm -rf charts
	#helm repo add bitnami https://charts.bitnami.com/bitnami
	#helm repo update bitnami
	#helm pull bitnami/kubeapps --untar --untardir charts
	#rm -rf charts/kubeapps/charts/postgresql/
	tag=$$(git ls-remote --tags --sort="v:refname" https://github.com/vmware-tanzu/kubeapps  | awk -F'[/^]' 'END{print $$3}') && \
	wget https://github.com/vmware-tanzu/kubeapps/raw/$${tag}/dashboard/Dockerfile -O images/dashboard/Dockerfile && \
	wget https://github.com/vmware-tanzu/kubeapps/raw/$${tag}/cmd/kubeapps-apis/Dockerfile -O images/kubeapps-apis/Dockerfile && \
	patch images/kubeapps-apis/Dockerfile < images/kubeapps-apis/dockerfile.diff


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
