NAME=fluxcd
NAMESPACE=cozy-$(NAME)

apply-locally:
	helm upgrade -i -n $(NAMESPACE) $(NAME) .

include ../../../scripts/package.mk
