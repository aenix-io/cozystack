export NAME=seaweedfs-operator
export NAMESPACE=cozy-$(NAME)

include ../../../scripts/package-system.mk

update:
	rm -rf charts
	mkdir -p charts/seaweedfs-operator
	curl -sSL https://github.com/seaweedfs/seaweedfs-operator/archive/refs/heads/master.tar.gz | \
	tar -C charts/seaweedfs-operator -xzvf - --strip 3 seaweedfs-operator-master/deploy/helm


show-locally:
	helm template --dry-run=server --post-renderer ../../../scripts/fluxcd-kustomize.sh -n $(NAMESPACE) $(NAME) . -f -
