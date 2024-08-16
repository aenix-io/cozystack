include ../../../scripts/package.mk

generate:
	readme-generator -v values.yaml -s values.schema.json.tmp -r README.md
	cat values.schema.json.tmp | jq '.properties.httpAndHttps.properties.mode.enum = ["tcp","tcp-with-proxy"]' > values.schema.json
	rm -f values.schema.json.tmp
