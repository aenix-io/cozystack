NAME=cert-manager-issuers
NAMESPACE=cozy-cert-manager

show:
	helm template -n $(NAMESPACE) $(NAME) .

apply:
	helm upgrade -i -n $(NAMESPACE) $(NAME) .

diff:
	helm diff upgrade --allow-unreleased -n $(NAMESPACE) $(NAME) .
