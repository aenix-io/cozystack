NAME=kafka-operator
NAMESPACE=cozy-kafka-operator

show:
	helm template --dry-run=server -n $(NAMESPACE) $(NAME) .

apply:
	helm upgrade -i -n $(NAMESPACE) $(NAME) .

diff:
	helm diff upgrade --allow-unreleased --normalize-manifests -n $(NAMESPACE) $(NAME) .

update:
	rm -rf charts
	helm pull oci://quay.io/strimzi-helm/strimzi-kafka-operator --untar --untardir charts
