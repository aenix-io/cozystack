export NAME=victoria-logs

include ../../../scripts/package.mk

update:
	rm -rf charts
	# VictoriaLogs
	helm repo add vm https://victoriametrics.github.io/helm-charts/
	helm repo update vm
	helm pull vm/victoria-logs-single --untar --untardir charts
	rm -rf charts/victoria-logs-single/charts/fluent-bit
