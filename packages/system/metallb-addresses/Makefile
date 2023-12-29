NAME=metallb-addresses
NAMESPACE=cozy-metallb

show:
	helm template -n $(NAMESPACE) $(NAME) .

apply:
	helm upgrade -i -n $(NAMESPACE) $(NAME) .

diff:
	helm diff upgrade --allow-unreleased -n $(NAMESPACE) $(NAME) .
