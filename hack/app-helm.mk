PUSH := 1
LOAD := 0

.DEFAULT_GOAL=help
.PHONY=help show diff apply delete update image

help:
	@echo "USAGE\n"
	@echo "Show app manifests:\n\
		make show ENV=<environment_name> INSTANCE=<instance_name>\n"
	@echo "Diff app manifests:\n\
		make diff ENV=<environment_name> INSTANCE=<instance_name>\n"
	@echo "Deploy app manifests:\n\
		make show ENV=<environment_name> INSTANCE=<instance_name>\n"
	@echo "Delete app manifests:\n\
		make diff ENV=<environment_name> INSTANCE=<instance_name>\n"
	@make -sq update 2>/dev/null || [ "$$?" != 1 ] \
	|| echo "Download app manifests from upstream\n\
		make update\n"
	@make -sq image 2>/dev/null || [ "$$?" != 1 ] \
	|| echo "Build docker image\n\
		make image PUSH=<0|1> PULL=<0|1>\n"

show diff apply delete:
	@../../hack/app-helm.sh $@
