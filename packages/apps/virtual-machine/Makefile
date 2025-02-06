include ../../../scripts/package.mk

generate:
	readme-generator -v values.yaml -s values.schema.json -r README.md
	INSTANCE_TYPES=$$(yq e '.metadata.name' -o=json -r ../../system/kubevirt-instancetypes/templates/instancetypes.yaml | yq 'split(" ") | . + [""]' -o json) \
	  && yq -i -o json ".properties.instanceType.optional=true | .properties.instanceType.enum = $${INSTANCE_TYPES}" values.schema.json
	PREFERENCES=$$(yq e '.metadata.name' -o=json -r ../../system/kubevirt-instancetypes/templates/preferences.yaml | yq 'split(" ") | . + [""]' -o json) \
	  && yq -i -o json ".properties.instanceProfile.optional=true | .properties.instanceProfile.enum = $${PREFERENCES}" values.schema.json
	yq -i -o json '.properties.externalPorts.items.type = "integer"' values.schema.json
	yq -i -o json '.properties.systemDisk.properties.image.enum = ["ubuntu", "cirros", "alpine", "fedora", "talos"]' values.schema.json
	yq -i -o json '.properties.externalMethod.enum = ["wholeIP", "PortList"]' values.schema.json
