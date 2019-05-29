.DEFAULT_GOAL := all

# Include .env configuration
include .env
export

##@ Basic usage

.PHONY: all
all: db/extensions/postgis ## Build all

.PHONY: clean
clean: dropdb removefiles ## Clean data files and databases

.PHONY: help
help:  ## Display this help
	@awk 'BEGIN {FS = ":.*##"; printf "\nUsage:\n  make \033[36m<target>\033[0m\n"} /^[a-zA-Z\%\\.\/_-]+:.*?##/ { printf "\033[36m%-15s\033[0m %s\n", $$1, $$2 } /^##@/ { printf "\n\033[1m%s\033[0m\n", substr($$0, 5) } ' $(MAKEFILE_LIST)

##@ Database

define create_extension
	@(psql -c "\dx $(subst db/extensions/,,$@)" | grep $(subst db/extensions/,,$@) > /dev/null 2>&1 && \
		echo "extension $(subst db/extensions/,,$@) exists") || \
	psql -v ON_ERROR_STOP=1 -qX1ec "CREATE EXTENSION $(subst db/extensions/,,$@)"
endef

.PHONY: db
db: ## Create database
	@(psql -c "SELECT 1" > /dev/null 2>&1 && \
		echo "database $(PGDATABASE) exists")|| \
	createdb -e $(PGDATABASE)

.PHONY: db/extensions/%
db/extensions/%: db ## Create extension `%` (where `%` is 'hstore', 'postgis', etc).
	$(call create_extension)

.PHONY: dropdb
dropdb: ## Drop database
	@psql -c "SELECT 1" > /dev/null 2>&1 && \
	dropdb -e $(PGDATABASE)

##@ Utilities

.PHONY: removefiles
removefiles: ## Remove data files
	find data ! -name '.*' ! -type d -exec rm -- {} +
