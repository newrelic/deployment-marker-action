#############################
# Global vars
#############################
PROJECT_NAME := $(shell basename $(shell pwd))
PROJECT_VER  ?= $(shell git describe --tags --always --dirty | sed -e '/^v/s/^v\(.*\)$$/\1/g')
# Last released version (not dirty) without leading v
PROJECT_VER_TAGGED  := $(shell git describe --tags --always --abbrev=0 | sed -e '/^v/s/^v\(.*\)$$/\1/g')

SRCDIR       ?= .
RELEASE_SCRIPT ?= ./scripts/release.sh

all:
	@echo "=== $(PROJECT_NAME) === [ all             ]: Supported targets:"
	@echo "  release      - Create new release"


# Example usage: make release version=0.11.0
release:
	@echo "=== $(PROJECT_NAME) === [ release          ]: Generating release."
	$(RELEASE_SCRIPT) $(version)


.PHONY: all build
