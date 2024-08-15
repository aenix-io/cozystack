include ../../../scripts/package.mk

generate:
	readme-generator -v values.yaml -s values.schema.json.tmp -r README.md
	cat values.schema.json.tmp | \
		jq '.properties.image.enum = ["ubuntu", "cirros", "alpine", "fedora"]' | \
		jq '.properties.resources.properties.memory["x-display"] = "slider"' \
		> values.schema.json
	rm -f values.schema.json.tmp
