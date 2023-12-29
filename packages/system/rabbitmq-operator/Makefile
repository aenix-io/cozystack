NAME=rabbitmq-operator
NAMESPACE=cozy-rabbitmq-operator

show:
	helm template -n $(NAMESPACE) $(NAME) .

apply:
	helm upgrade -i -n $(NAMESPACE) $(NAME) .

diff:
	helm diff upgrade --allow-unreleased -n $(NAMESPACE) $(NAME) .

update:
	rm -rf templates/cluster-operator.yml
	wget -O templates/cluster-operator.yml https://github.com/rabbitmq/cluster-operator/releases/latest/download/cluster-operator.yml
	yq -i 'del(select(.kind=="Namespace"))' templates/cluster-operator.yml
	sed -i 's/rabbitmq-system/cozy-rabbitmq-operator/g' templates/cluster-operator.yml
