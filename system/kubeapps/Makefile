include ../../hack/app-helm.mk

update:
	rm -rf charts
	helm repo add bitnami https://charts.bitnami.com/bitnami
	helm repo update bitnami
	helm pull bitnami/kubeapps --untar --untardir charts
	rm -rf charts/kubeapps/charts/postgresql/
