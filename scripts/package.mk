.DEFAULT_GOAL=help
.PHONY=help show diff apply delete update image
.VALUES_FILES=$(shell kubectl get hr -n $(NAMESPACE) $(NAME) -o go-template='{{ range .spec.chart.spec.valuesFiles}}-f {{ . }} {{ end }}-f -')

help: ## Show this help.
	@awk 'BEGIN {FS = ":.*?## "} /^[a-zA-Z_-]+:.*?## / {sub("\\\\n",sprintf("\n%22c"," "), $$2);printf "\033[36m%-20s\033[0m %s\n", $$1, $$2}' $(MAKEFILE_LIST)

show: check ## Show output of rendered templates
	kubectl get hr -n $(NAMESPACE) $(NAME) -o jsonpath='{.spec.values}' | NAMESPACE=$(NAMESPACE) NAME=$(NAME) \
		helm template --dry-run=server --post-renderer ../../../scripts/fluxcd-kustomize.sh -n $(NAMESPACE) $(NAME) . $(.VALUES_FILES)

apply: check suspend ## Apply Helm release to a Kubernetes cluster
	kubectl get hr -n $(NAMESPACE) $(NAME) -o jsonpath='{.spec.values}' | NAMESPACE=$(NAMESPACE) NAME=$(NAME) \
		helm upgrade -i --post-renderer ../../../scripts/fluxcd-kustomize.sh -n $(NAMESPACE) $(NAME) . $(.VALUES_FILES)

diff: check ## Diff Helm release against objects in a Kubernetes cluster
	kubectl get hr -n $(NAMESPACE) $(NAME) -o jsonpath='{.spec.values}' | NAMESPACE=$(NAMESPACE) NAME=$(NAME) \
		helm diff upgrade --dry-run=server --show-secrets --allow-unreleased --post-renderer ../../../scripts/fluxcd-kustomize.sh -n $(NAMESPACE) $(NAME) . $(.VALUES_FILES)

suspend: check ## Suspend reconciliation for an existing Helm release
	kubectl patch hr -n $(NAMESPACE) $(NAME) -p '{"spec": {"suspend": true}}' --type=merge --field-manager=flux-client-side-apply

resume: check ## Resume reconciliation for an existing Helm release
	kubectl patch hr -n $(NAMESPACE) $(NAME) -p '{"spec": {"suspend": null}}' --type=merge --field-manager=flux-client-side-apply

delete: check suspend ## Delete Helm release from a Kubernetes cluster
	helm uninstall -n $(NAMESPACE) $(NAME)

check:
	@if [ -z "$(NAME)" ]; then echo "env NAME is not set!" >&2; exit 1; fi
	@if [ -z "$(NAMESPACE)" ]; then echo "env NAMESPACE is not set!" >&2; exit 1; fi
