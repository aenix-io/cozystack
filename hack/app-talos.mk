.DEFAULT_GOAL=help
.PHONY=init gen clean members diff apply dashboard

help:
	@echo "USAGE\n"
	@echo "Prepare secrets and basic files for new cluster:\n\
		make init\n"
	@echo "Generate configuration files:\n\
		make gen\n"
	@echo "Remove generated files:\n\
		make clean\n"
	@echo "Show etcd members:\n\
		make members\n"
	@echo "Diff currently generated configuration:\n\
		make diff\n"
	@echo "Apply currently generated configuration to the cluster:\n\
		make apply\n"
	@echo "Show dashboard:\n\
		make dashboard\n"

init gen clean members diff apply dashboard:
	@../../hack/app-talos.sh $@
