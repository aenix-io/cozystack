export NAME=redis-operator
export NAMESPACE=cozy-$(NAME)

include ../../../scripts/package.mk

update:
	rm -rf charts
	helm repo add redis-operator https://spotahome.github.io/redis-operator
	helm repo update redis-operator
	helm pull redis-operator/redis-operator --untar --untardir charts
	sed -i '/{{/d' charts/redis-operator/crds/databases.spotahome.com_redisfailovers.yaml
