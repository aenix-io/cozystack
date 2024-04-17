NAME=mariadb-operator
NAMESPACE=cozy-$(NAME)

include ../../hack/package-system.mk

update:
	rm -rf charts
	helm repo add $(NAME) https://$(NAME).github.io/$(NAME)
	helm repo update $(NAME)
	helm pull $(NAME)/$(NAME) --untar --untardir charts
