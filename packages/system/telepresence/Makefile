export NAME=traffic-manager
export NAMESPACE=cozy-telepresence

include ../../../scripts/package.mk

update:
	rm -rf charts
	helm repo add datawire https://app.getambassador.io
	helm repo update datawire
	helm pull datawire/telepresence --untar --untardir charts
