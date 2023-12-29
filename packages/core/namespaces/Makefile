NAMESPACE=cozy-system
NAME=namespaces

show:
	helm template -n $(NAMESPACE) $(NAME) .

apply:
	helm template -n $(NAMESPACE) $(NAME) . | kubectl apply -f-

diff:
	helm diff upgrade --allow-unreleased -n $(NAMESPACE) $(NAME) .
