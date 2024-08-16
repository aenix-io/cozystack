export NAME=cosi-controller
export NAMESPACE=cozy-$(NAME)

include ../../../scripts/package.mk

update:
	rm -rf templates
	mkdir templates
	kubectl kustomize github.com/kubernetes-sigs/container-object-storage-interface-api > templates/crds.yaml
	kubectl kustomize github.com/kubernetes-sigs/container-object-storage-interface-controller > templates/controller.yaml
	sed -i 's/namespace: default/namespace: {{ .Release.Namespace }}/g' templates/controller.yaml
