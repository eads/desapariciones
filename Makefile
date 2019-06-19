################################################################################
#
# Process data related to disappearances in Mexico.
#
# Run make help to see all commands.
#
# make all will build the site.
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

PIPENV = pipenv run
DATAFILES = cenapi rnpedfc rnpedff

##@ Basic usage

.DEFAULT_GOAL := all
.PHONY: all
all: tables maps ## Build all

.PHONY: tables
tables: $(patsubst %, db/csv/%, $(DATAFILES))  ## Make all tables from data files

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

define create_table
	@(psql -c "\d $(subst db/tables/,,$@)" > /dev/null 2>&1 && \
		echo "table $(subst db/tables/,,$@) exists") || \
	psql -v ON_ERROR_STOP=1 -qX1ef $<
endef

define create_schema
	@(psql -c "\dn $(subst db/schemas/,,$@)" | grep $(subst db/schemas/,,$@) > /dev/null 2>&1 && \
	  echo "schema $(subst db/schemas/,,$@) exists") || \
	psql -v ON_ERROR_STOP=1 -qaX1ec "CREATE SCHEMA $(subst db/schemas/,,$@)"
endef

define load_shapefile
	@(psql -c "\d $(subst db/shapefiles/,,$@)" > /dev/null 2>&1 && \
	 echo "table $(subst db/shapefiles/,,$@) exists")	|| \
	shp2pgsql $(1) $< $(subst db/shapefiles/,,$@) | psql -v ON_ERROR_STOP=1 -q
endef

define load_csv
	@(psql -Atc "select count(*) from $(subst db/csv/,,$@)" | grep -v -w "0" > /dev/null 2>&1 && \
	 	echo "$(subst db/csv/,,$@) is not empty") || \
	psql -v ON_ERROR_STOP=1 -qX1ec "\copy $(subst db/csv/,,$@) from '$(CURDIR)/$<' with delimiter ',' csv header;"
endef

.PHONY: db
db: ## Create database
	@(psql -c "SELECT 1" > /dev/null 2>&1 && \
		echo "database $(PGDATABASE) exists") || \
	createdb -e $(PGDATABASE)

.PHONY: db/extensions/%
db/extensions/%: db ## Create extension % (where % is 'hstore', 'postgis', etc)
	$(call create_extension)

.PHONY: db/schemas/%
db/schemas/%: db ## Create schema % (where % is 'raw', etc)
	$(call create_schema)

.PHONY: db/tables/%
db/tables/%: sql/tables/%.sql db  ## Create table % from sql/tables/%.sql
	$(call create_table)

.PHONY: db/shapefiles/%
db/shapefiles/%: data/shapefiles/%.shp db/extensions/postgis ## Load table % from data/shapefiles/%.shp
	$(call load_shapefile, "-s 6372:3857")

.PHONY: db/csv/%
db/csv/%: data/processed/%.csv db/tables/% db ## Load table % from data/downloads/%.csv
	$(call load_csv)

.PHONY: dropdb
dropdb: ## Drop database
	dropdb --if-exists -e $(PGDATABASE)


##@ Source data

.PHONY: download/shapefiles
download/shapefiles: data/downloads/marcos_geoestadicos_2017.zip ## Download shapefiles

.PHONY: download/gdrive
download/gdrive: $(patsubst %, data/downloads/%.csv, $(DATAFILES)) ## Download all Drive files

data/downloads/marcos_geoestadicos_2017.zip: # Download INEGI shapefiles (geostatistical shapes)
	curl -o $@ http://internet.contenidos.inegi.org.mx/contenidos/Productos/prod_serv/contenidos/espanol/bvinegi/productos/geografia/marcogeo/889463142683_s.zip

$(INEGI_FILES): data/downloads/marcos_geoestadicos_2017.zip # Unzip INEGI shapefiles (see Makefile.vars for definition)
	unzip -j -o $< -d data/shapefiles && touch $(INEGI_FILES)

data/downloads/%.csv: secrets/rclone.conf # Download %.csv from Google Drive
	rclone --config $< copy mapadespariciones:$(@F) $(@D) && touch $@


##@ Process data

.PRECIOUS: data/processed/%.csv
data/processed/%.csv: data/downloads/%.csv # Convert encoding
	iconv -f iso-8859-1 -t utf-8 $< > $@

.PRECIOUS: data/stats/%.csv
data/stats/%.csv: data/downloads/%.csv # Get column stats and metadata with xsv
	xsv stats $< > $@

.PRECIOUS: sql/tables/%.sql
sql/tables/%.sql: data/stats/%.csv # Parse column stats into SQL schema for import
	$(PIPENV) python processors/schema.py $< $@

##@ Utilities

DATA_DIRECTORIES = shapefiles processed stats
DOWNLOAD_DIRECTORIES = downloads

.PHONY: dbshell
dbshell:  ## Log in to database configured in .env.
	psql

.PHONY: install
install: install/npm install/pipenv ## Install project Node and Python dependencies

.PHONY: install/npm
install/npm: # Install from NPM
	npm install

.PHONY: install/pipenv
install/pipenv: # Install pipenv
	pipenv install

.PHONY: clean/data
clean/data: $(patsubst %, rm/%, $(DATA_DIRECTORIES)) ## Remove all data files
	rm -rf sql/tables/*

.PHONY: clean/downloads
clean/downloads: $(patsubst %, rm/%, $(DOWNLOAD_DIRECTORIES)) ## Remove all downloads

.PHONY: rm/%
rm/%: # Remove data/% where % is a directory name
	rm -rf data/$*/*
