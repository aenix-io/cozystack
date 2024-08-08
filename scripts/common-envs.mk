REGISTRY := ghcr.io/aenix-io/cozystack

PUSH := 1
LOAD := 0
VERSION = $(patsubst v%,%,$(shell git describe --tags --abbrev=0))
TAG = $(shell git describe --tags --exact-match 2>/dev/null || echo latest)

# Returns 'latest' if the git tag is not assigned, otherwise returns the provided value
define settag
$(if $(filter $(TAG),latest),latest,$(1))
endef
