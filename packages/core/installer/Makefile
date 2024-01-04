NAMESPACE=cozy-installer
NAME=installer
PUSH=1
LOAD=0

show:
	helm template -n $(NAMESPACE) $(NAME) .

apply:
	helm template -n $(NAMESPACE) $(NAME) . | kubectl apply -f -

diff:
	helm template -n $(NAMESPACE) $(NAME) . | kubectl diff -f -

image:
	#docker build -f images/installer/Dockerfile ../../..
	docker buildx build -f images/installer/Dockerfile ../../.. \
		--provenance false \
		--tag ghcr.io/aenix-io/cozystack/installer:latest \
		--cache-from type=registry,ref=ghcr.io/aenix-io/cozystack/installer:latest \
		--cache-to type=inline \
		--metadata-file images/installer.json \
		--push=$(PUSH) \
		--load=$(LOAD)

