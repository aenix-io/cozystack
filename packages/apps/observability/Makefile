update:
	rm -rf charts
	helm repo add grafana https://grafana.github.io/helm-charts
	helm repo update grafana
	helm pull grafana/oncall --untar --untardir charts
	rm -rf charts/oncall/charts
	patch -p4 < patches/1.diff
	yq e -i '.database.type="postgresql"' charts/oncall/values.yaml
	yq e -i '.broker.type="redis"' charts/oncall/values.yaml
	yq e -i '.ingress.enabled=false' charts/oncall/values.yaml
	yq e -i '.cert-manager.enabled=false' charts/oncall/values.yaml
	yq e -i '.mariadb.enabled=false' charts/oncall/values.yaml
	yq e -i '.postgresql.enabled=false' charts/oncall/values.yaml
	yq e -i '.rabbitmq.enabled=false' charts/oncall/values.yaml
	yq e -i '.redis.enabled=false' charts/oncall/values.yaml
	yq e -i '.grafana.enabled=false' charts/oncall/values.yaml

dashboards-list:
	find ../../../dashboards -name '*.json' | awk -F/ '{sub(".json", ""); printf "%s/%s\n", $$(NF-1), $$NF}' > dashboards.list
