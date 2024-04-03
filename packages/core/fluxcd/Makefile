NAMESPACE=cozy-fluxcd
NAME=fluxcd

API_VERSIONS_FLAGS=$(addprefix -a ,$(shell kubectl api-versions))

show:
	helm template -n $(NAMESPACE) $(NAME) . --no-hooks --dry-run=server $(API_VERSIONS_FLAGS)

apply:
	helm template -n $(NAMESPACE) $(NAME) . --no-hooks --dry-run=server $(API_VERSIONS_FLAGS) | kubectl apply -n $(NAMESPACE) -f-

diff:
	helm template -n $(NAMESPACE) $(NAME) . --no-hooks --dry-run=server $(API_VERSIONS_FLAGS) | kubectl diff -n $(NAMESPACE) -f-
