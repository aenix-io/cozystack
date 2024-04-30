NAME=platform
NAMESPACE=cozy-system

API_VERSIONS_FLAGS=$(addprefix -a ,$(shell kubectl api-versions))

show:
	helm template -n $(NAMESPACE) $(NAME) . --dry-run=server $(API_VERSIONS_FLAGS)

apply:
	helm template -n $(NAMESPACE) $(NAME) . --dry-run=server $(API_VERSIONS_FLAGS) | kubectl apply -f-

namespaces-show:
	helm template -n $(NAMESPACE) $(NAME) . --dry-run=server $(API_VERSIONS_FLAGS) -s templates/namespaces.yaml

namespaces-apply:
	helm template -n $(NAMESPACE) $(NAME) . --dry-run=server $(API_VERSIONS_FLAGS) -s templates/namespaces.yaml | kubectl apply -n $(NAMESPACE) -f-

diff:
	helm template -n $(NAMESPACE) $(NAME) . --dry-run=server $(API_VERSIONS_FLAGS) | kubectl diff -f-
