NAME=ingress-nginx
NAMESPACE=cozy-$(NAME)

include ../../hack/package-system.mk

update:
	rm -rf charts
	helm repo add $(NAME) https://kubernetes.github.io/$(NAME)
	helm repo update $(NAME)
	helm pull $(NAME)/$(NAME) --untar --untardir charts
	patch -p 3 < patches/add-metrics2.patch
	rm -f charts/$(NAME)/templates/controller-deployment.yaml.orig
	rm -rf charts/$(NAME)/changelog/
	#sed -i '/  type:/a \  allocateLoadBalancerNodePorts: false' charts/$(NAME)/templates/controller-service.yaml
