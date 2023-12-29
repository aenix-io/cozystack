include ../../hack/app-helm.mk

update:
	rm -rf charts
	helm repo add kube-vip https://kube-vip.github.io/helm-charts
	helm repo update kube-vip
	helm pull kube-vip/kube-vip-cloud-provider --untar --untardir charts
	helm pull kube-vip/kube-vip --untar --untardir charts
