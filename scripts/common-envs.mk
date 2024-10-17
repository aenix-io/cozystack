REGISTRY := ghcr.io/aenix-io/cozystack
PUSH := 1
LOAD := 0
VERSION = $(patsubst v%,%,$(shell git describe --tags --abbrev=0))
TAG = $(shell git describe --tags --exact-match 2>/dev/null || echo latest)

# Returns 'latest' if the git tag is not assigned, otherwise returns the provided value
define settag
$(if $(filter $(TAG),latest),latest,$(1))
endef

ifeq ($(VERSION),)
    $(shell git remote add upstream https://github.com/aenix-io/cozystack.git || true)
    $(shell git fetch upstream --tags)
    VERSION = $(patsubst v%,%,$(shell git describe --tags --abbrev=0))
endif
