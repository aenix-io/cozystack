NAMESPACE=cozy-fluxcd
NAME=fluxcd

show:
	helm template --dry-run=server -n $(NAMESPACE) $(NAME) .

apply:
	helm upgrade -i -n $(NAMESPACE) $(NAME) .

apply-crds:
	helm template -n $(NAMESPACE) $(NAME) . $(addprefix -s ,$(wildcard charts/flux2/templates/*.crds.yaml)) | kubectl apply -f -
	kubectl annotate $$(kubectl get crd -o name | grep '\.fluxcd\.io$$') meta.helm.sh/release-namespace=$(NAMESPACE) meta.helm.sh/release-name=$(NAME)
	kubectl label $$(kubectl get crd -o name | grep '\.fluxcd\.io$$') app.kubernetes.io/managed-by=Helm

diff-crds:
	helm template -n $(NAMESPACE) $(NAME) . $(addprefix -s ,$(wildcard charts/flux2/templates/*.crds.yaml)) | kubectl apply -f -

diff:
	helm diff upgrade --allow-unreleased --normalize-manifests -n $(NAMESPACE) $(NAME) .

update:
	rm -rf charts
	helm pull oci://ghcr.io/fluxcd-community/charts/flux2 --untar --untardir charts
