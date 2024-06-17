NAME=fluxcd
NAMESPACE=cozy-$(NAME)

API_VERSIONS_FLAGS=$(addprefix -a ,$(shell kubectl api-versions))

show:
	helm template -n $(NAMESPACE) $(NAME) . --no-hooks --dry-run=server $(API_VERSIONS_FLAGS)

apply:
	helm template -n $(NAMESPACE) $(NAME) . --no-hooks -f valuesFile.yaml -f flux-customizations.yaml \
		--dry-run=server $(API_VERSIONS_FLAGS) | kubectl apply -n $(NAMESPACE) -f-

diff:
	helm template -n $(NAMESPACE) $(NAME) . --no-hooks -f valuesFile.yaml -f flux-customizations.yaml \
		--dry-run=server $(API_VERSIONS_FLAGS) | kubectl diff -n $(NAMESPACE) -f-

update:
	rm -rf charts
	helm pull oci://ghcr.io/controlplaneio-fluxcd/charts/flux-operator --untar --untardir charts
