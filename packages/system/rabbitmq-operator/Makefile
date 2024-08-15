export NAME=rabbitmq-operator
export NAMESPACE=cozy-$(NAME)

include ../../../scripts/package.mk

update:
	rm -rf templates/cluster-operator.yml
	wget -O templates/cluster-operator.yml https://github.com/rabbitmq/cluster-operator/releases/latest/download/cluster-operator.yml
	yq -i 'del(select(.kind=="Namespace"))' templates/cluster-operator.yml
	sed -i 's/rabbitmq-system/$(NAMESPACE)/g' templates/cluster-operator.yml
