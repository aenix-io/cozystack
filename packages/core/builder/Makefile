NAMESPACE=cozy-builder
NAME := builder

TALOS_VERSION=$(shell awk '/^version:/ {print $$2}' ../installer/images/talos/profiles/installer.yaml)

include ../../../scripts/common-envs.mk

help: ## Show this help.
	@awk 'BEGIN {FS = ":.*?## "} /^[a-zA-Z_-]+:.*?## / {sub("\\\\n",sprintf("\n%22c"," "), $$2);printf "\033[36m%-20s\033[0m %s\n", $$1, $$2}' $(MAKEFILE_LIST)

show:
	helm template -n $(NAMESPACE) $(NAME) .

apply: ## Create builder sandbox in existing Kubernetes cluster.
	helm template -n $(NAMESPACE) $(NAME) . | kubectl apply -f -
	docker buildx ls | grep -q '^buildkit-builder*' || docker buildx create \
		--bootstrap \
		--name=buildkit-$(NAME) \
		--driver=kubernetes \
		--driver-opt=namespace=$(NAMESPACE),replicas=1 \
		--platform=linux/amd64 \
		--platform=linux/arm64 \
		--use \
		--config config.toml

diff:
	helm template -n $(NAMESPACE) $(NAME) . | kubectl diff -f -

delete: ## Remove builder sandbox from existing Kubernetes cluster.
	kubectl delete deploy -n $(NAMESPACE) $(NAME)-talos-imager
	docker buildx rm buildkit-$(NAME)

wait-for-builder:
	kubectl wait deploy --for=condition=Progressing -n $(NAMESPACE) $(NAME)-talos-imager
	kubectl wait pod --for=condition=Ready -n $(NAMESPACE) -l app=$(NAME)-talos-imager
