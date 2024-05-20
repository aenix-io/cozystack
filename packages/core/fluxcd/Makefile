NAME=fluxcd
NAMESPACE=cozy-$(NAME)

API_VERSIONS_FLAGS=$(addprefix -a ,$(shell kubectl api-versions))

show:
	helm template -n $(NAMESPACE) $(NAME) . --no-hooks --dry-run=server $(API_VERSIONS_FLAGS)

apply:
	helm template -n $(NAMESPACE) $(NAME) . --no-hooks --dry-run=server $(API_VERSIONS_FLAGS) | kubectl apply -n $(NAMESPACE) -f-

diff:
	helm template -n $(NAMESPACE) $(NAME) . --no-hooks --dry-run=server $(API_VERSIONS_FLAGS) | kubectl diff -n $(NAMESPACE) -f-

update:
	rm -rf charts
	helm repo add fluxcd-community https://fluxcd-community.github.io/helm-charts
	helm repo update fluxcd-community
	helm pull fluxcd-community/flux2 --untar --untardir charts
	sed -i 's/\.{{ \.Values\.clusterDomain | default "cluster\.local" }}\.//g' `grep -rl '.{{ .Values.clusterDomain | default "cluster.local" }}.' charts`
