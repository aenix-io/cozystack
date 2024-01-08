update:
	rm -rf charts
	helm repo add grafana https://grafana.github.io/helm-charts
	helm repo update grafana
	helm pull grafana/oncall --untar --untardir charts
	rm -rf charts/oncall/charts
	hack/download-dashboards.sh

define dashboards_show
	@git diff --exit-code .helmignore
	@trap 'git checkout .helmignore' EXIT INT && \
	sed -i.bak '/grafana-dashboards/d' .helmignore && \
	make show | yq e "select(.kind|downcase == \"grafanadashboard\")"
endef

.PHONY=dashboards-show
dashboards-show:
	$(call dashboards_show)

.PHONY=dashboards-apply
dashboards-apply:
	$(call dashboards_show) | kubectl apply --server-side=true --force-conflicts -f -

.PHONY=dashboards-diff
dashboards-diff:
	$(call dashboards_show) | kubectl diff --server-side=true --force-conflicts -f -
