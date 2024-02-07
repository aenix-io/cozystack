NAMESPACE=cozy-installer
NAME=installer
PUSH := 1
LOAD := 0
REGISTRY := ghcr.io/aenix-io/cozystack
TAG := v0.0.1

show:
	helm template -n $(NAMESPACE) $(NAME) .

apply:
	helm template -n $(NAMESPACE) $(NAME) . | kubectl apply -f -

diff:
	helm template -n $(NAMESPACE) $(NAME) . | kubectl diff -f -

image:
	docker buildx build -f images/installer/Dockerfile ../../.. \
		--provenance false \
		--tag $(REGISTRY)/installer:$(TAG) \
		--cache-from type=registry,ref=$(REGISTRY)/installer:$(TAG) \
		--cache-to type=inline \
		--metadata-file images/installer.json \
		--push=$(PUSH) \
		--load=$(LOAD)
	echo "$(REGISTRY)/installer:$(TAG)" > images/installer.tag
