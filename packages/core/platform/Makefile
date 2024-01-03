NAMESPACE=cozy-system
NAME=platform

show:
	helm template -n $(NAMESPACE) $(NAME) . --dry-run=server

apply:
	helm template -n $(NAMESPACE) $(NAME) . --dry-run=server | kubectl apply -f-

namespaces-show:
	helm template -n $(NAMESPACE) $(NAME) . --dry-run=server -s templates/namespaces.yaml

namespaces-apply:
	helm template -n $(NAMESPACE) $(NAME) . --dry-run=server -s templates/namespaces.yaml | kubectl apply -f-

diff:
	helm template -n $(NAMESPACE) $(NAME) . --dry-run=server -s templates/namespaces.yaml | kubectl diff -f-
