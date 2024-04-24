NAME=etcd-operator
NAMESPACE=cozy-etcd-operator

include ../../../scripts/package-system.mk

update:
	rm -rf charts
	helm pull oci://ghcr.io/aenix-io/charts/etcd-operator --untar --untardir charts
