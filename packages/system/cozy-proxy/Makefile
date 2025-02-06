NAME=cozy-proxy
NAMESPACE=cozy-system

include ../../../scripts/common-envs.mk
include ../../../scripts/package.mk

update:
	rm -rf charts
	tag=$$(git ls-remote --tags --sort="v:refname" https://github.com/aenix-io/cozy-proxy | awk -F'[/^]' 'END{print $$3}') && \
	curl -sSL https://github.com/aenix-io/cozy-proxy/archive/refs/tags/$${tag}.tar.gz | \
	tar xzvf - --strip 1 cozy-proxy-$${tag#*v}/charts
