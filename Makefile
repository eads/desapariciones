################################################################################
#
# Process data related to disappearances in Mexico.
#
# Run `make help` to see all commands.
#
# `make all` will build the site.
#
# This is an auto-documenting Makefile:
#
# Add sections to help with a line like:
#
#  ##@ Section Name
#
# Add commands by following a target line with a double-# comment
# like this:
#
#  clean: ## Delete all files".
#
################################################################################

# Include variables such as list of files from INEGI
include Makefile.vars

# Include .env configuration
include .env
export


##@ Basic usage

.DEFAULT_GOAL := all
.PHONY: all
all: maps ## Build all

.PHONY: maps
maps: db/shapefiles/areas_geoestadisticas_estatales db/shapefiles/areas_geoestadisticas_municipales ## Load all maps into database

.PHONY: clean
clean: dropdb clean/data ## Clean data files and databases (but not downloads)

.PHONY: help
help:  ## Display this help
	@awk 'BEGIN {FS = ":.*##"; printf "\nUsage:\n  make \033[36m<target>\033[0m\n"} /^[a-zA-Z\%\\.\/_-]+:.*?##/ { printf "\033[36m%-15s\033[0m %s\n", $$1, $$2 } /^##@/ { printf "\n\033[1m%s\033[0m\n", substr($$0, 5) } ' $(MAKEFILE_LIST)


##@ Database

define create_extension
	@(psql -c "\dx $(subst db/extensions/,,$@)" | grep $(subst db/extensions/,,$@) > /dev/null 2>&1 && \
		echo "extension $(subst db/extensions/,,$@) exists") || \
	psql -v ON_ERROR_STOP=1 -qX1ec "CREATE EXTENSION $(subst db/extensions/,,$@)"
endef

define load_shapefile
	@(psql -c "\d $(subst db/shapefiles/,,$@)" > /dev/null 2>&1 && \
	 echo "table $(subst db/shapefiles/,,$@) exists")	|| \
	shp2pgsql $(1) $< $(subst db/shapefiles/,,$@) | psql -v ON_ERROR_STOP=1 -q
endef

.PHONY: db
db: ## Create database
	@(psql -c "SELECT 1" > /dev/null 2>&1 && \
		echo "database $(PGDATABASE) exists") || \
	createdb -e $(PGDATABASE)

.PHONY: db/extensions/%
db/extensions/%: db ## Create extension `%` (where `%` is 'hstore', 'postgis', etc).
	$(call create_extension)

.PHONY: dropdb
dropdb: ## Drop database
	dropdb --if-exists -e $(PGDATABASE)


##@ Source data

data/downloads/marcos_geoestadicos_2017.zip: # Download INEGI shapefiles (geostatistical shapes)
	curl -o $@ http://internet.contenidos.inegi.org.mx/contenidos/Productos/prod_serv/contenidos/espanol/bvinegi/productos/geografia/marcogeo/889463142683_s.zip

$(INEGI_FILES): data/downloads/marcos_geoestadicos_2017.zip # Unzip INEGI shapefiles (see Makefile.vars for definition)
	unzip -j -o $< -d data/shapefiles && touch $(INEGI_FILES)

db/shapefiles/%: data/shapefiles/%.shp db/extensions/postgis ## Load table `%` from data/shapefiles/%.shp.
	$(call load_shapefile, "-s 6372:3857")


##@ Utilities

DATA_DIRECTORIES = shapefiles
DOWNLOAD_DIRECTORIES = downloads

.PHONY: clean/data
clean/data: $(patsubst %, rm/%, $(DATA_DIRECTORIES)) ## Remove all data files

.PHONY: clean/downloads
clean/downloads: $(patsubst %, rm/%, $(DOWNLOAD_DIRECTORIES)) ## Remove all downloads

.PHONY: rm/%
rm/%: ## Remove `data/%` where `%` is a directory name
	rm -rf data/$*/*
