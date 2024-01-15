update:
	rm -rf charts
	helm repo add grafana https://grafana.github.io/helm-charts
	helm repo update grafana
	helm pull grafana/oncall --untar --untardir charts
	rm -rf charts/oncall/charts

dashboards-list:
	find ../../../dashboards -name '*.json' | awk -F/ '{sub(".json", ""); printf "%s/%s\n", $$(NF-1), $$NF}' > dashboards.list
