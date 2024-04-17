NAME=traffic-manager
NAMESPACE=cozy-telepresence

include ../../hack/package-system.mk

update:
	rm -rf charts
	helm repo add datawire https://app.getambassador.io
	helm repo update datawire
	helm pull datawire/telepresence --untar --untardir charts
