NAME=piraeus-operator
NAMESPACE=cozy-linstor

show:
	helm template --dry-run=server -n $(NAMESPACE) $(NAME) .

apply:
	helm upgrade -i -n $(NAMESPACE) $(NAME) .

diff:
	helm diff upgrade --allow-unreleased --normalize-manifests -n $(NAMESPACE) $(NAME) .

update:
	rm -rf charts
	tag=$$(git ls-remote --tags --sort="v:refname" https://github.com/piraeusdatastore/piraeus-operator  | awk -F'[/^]' 'END{print $$3}') && \
	curl -sSL https://github.com/piraeusdatastore/piraeus-operator/archive/refs/tags/$${tag}.tar.gz | \
	tar xzvf - --strip 1 piraeus-operator-$${tag#*v}/charts
