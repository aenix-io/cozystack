NAME=redis-operator
NAMESPACE=cozy-$(NAME)

include ../../hack/package-system.mk

update:
	rm -rf charts
	helm repo add $(NAME) https://spotahome.github.io/$(NAME)
	helm repo update $(NAME)
	helm pull $(NAME)/$(NAME) --untar --untardir charts
	sed -i '/{{/d' charts/$(NAME)/crds/databases.spotahome.com_redisfailovers.yaml
