POSTGRES_BACKUP_TAG = $(shell awk '$$1 == "version:" {print $$2}' Chart.yaml)

include ../../../scripts/common-envs.mk
include ../../../scripts/package.mk

generate:
	readme-generator -v values.yaml -s values.schema.json -r README.md

image:
	docker buildx build --platform linux/amd64 --build-arg ARCH=amd64 images/postgres-backup \
		--provenance false \
		--tag $(REGISTRY)/postgres-backup:$(call settag,$(POSTGRES_BACKUP_TAG)) \
		--cache-from type=registry,ref=$(REGISTRY)/postgres-backup:latest \
		--cache-to type=inline \
		--metadata-file images/postgres-backup.json \
		--push=$(PUSH) \
		--load=$(LOAD)
	echo "$(REGISTRY)/postgres-backup:$(call settag,$(POSTGRES_BACKUP_TAG))@$$(yq e '."containerimage.digest"' images/postgres-backup.json -o json -r)" \
		> images/postgres-backup.tag
	cp images/postgres-backup.tag ../ferretdb/images/
	rm -f images/postgres-backup.json
