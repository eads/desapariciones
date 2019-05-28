.DEFAULT_GOAL := all

# Include .env configuration
include .env
export

##@ Basic usage

.PHONY: all
all: data/file.csv ## Build all

.PHONY: clean
clean: ## Clean data files and databases
	find data ! -name '.*' ! -type d -exec rm -- {} +

.PHONY: help
help:  ## Display this help
	@awk 'BEGIN {FS = ":.*##"; printf "\nUsage:\n  make \033[36m<target>\033[0m\n"} /^[a-zA-Z\\.\/_-]+:.*?##/ { printf "  \033[36m%-15s\033[0m %s\n", $$1, $$2 } /^##@/ { printf "\n\033[1m%s\033[0m\n", substr($$0, 5) } ' $(MAKEFILE_LIST)

##@ Database

db:
	@psql -c "SELECT 1" > /dev/null 2>&1 || \
	createdb

db/extensions/%: db
	$(call create_extension)
