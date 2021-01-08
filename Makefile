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

# Activate Python environment
PIPENV = pipenv run

# Functions can be found in sql/functions
FUNCTIONS = $(basename $(notdir $(wildcard sql/functions/*.sql)))

# Views can be found in sql/views
VIEWS = $(basename $(notdir $(wildcard sql/views/*.sql)))

# Schemas are used to compartmentalize various types of data tables or views
SCHEMAS = views processed raw

# Data and map tables need to be statically defined; they depend on remote files
DATAFILES = cenapi base_municipios_datos
SHAPEFILES = areas_geoestadisticas_estatales areas_geoestadisticas_municipales

# Different directories we can clean
DATA_DIRECTORIES = shapefiles processed stats geojson mbtiles
DOWNLOAD_DIRECTORIES = downloads


##@ Basic usage

.DEFAULT_GOAL := all
.PHONY: all
all: views ## Build all

.PHONY: views
views: load $(patsubst %, db/views/%, $(VIEWS)) ## Make all views

.PHONY: load
load: csvs shapefiles $(patsubst %, db/processed/%, $(DATAFILES)) $(patsubst %, db/processed/%, $(SHAPEFILES)) ## Make all tables from data files

.PHONY: csvs
csvs: $(patsubst %, db/csv/%, $(DATAFILES))

.PHONY: shapefiles
shapefiles: $(patsubst %, db/shapefiles/%, $(SHAPEFILES))

.PHONY: clean
clean: dropdb clean/data ## Clean data files and databases (but not downloads)

.PHONY: help
help:  ## Display this help
	@awk 'BEGIN {FS = ":.*##"; printf "\nUsage:\n  make \033[36m<target>\033[0m\n"} /^[a-zA-Z\%\\.\/_-]+:.*?##/ { printf "\033[36m%-15s\033[0m %s\n", $$1, $$2 } /^##@/ { printf "\n\033[1m%s\033[0m\n", substr($$0, 5) } ' $(MAKEFILE_LIST)


##@ Database views
# These are explicitly defined because the dependency graph must be manually specified.

define create_view
	@(psql -c "\d views.$(subst db/views/,,$@)" > /dev/null 2>&1 && \
		echo "view $(subst db/views/,,$@) exists") || \
	psql -v ON_ERROR_STOP=1 -qX1ef $<
endef

.PHONY: db/views/%
db/views/%: sql/views/%.sql load  ## Create view % specified in sql/views/%.sql (will load all data)
	$(call create_view)

.PHONY: db/views/date_distributions
db/views/date_distribution: sql/views/date_distribution.sql db/processed/cenapi db/functions/calculate_percentiles
	$(call create_view)

.PHONY: db/views/cenapi_estado_by_month
db/views/cenapi_estado_by_month: sql/views/cenapi_estado_by_month.sql db/views/estatales db/views/municipales
	$(call create_view)

.PHONY: db/views/cenapi_estado_by_year
db/views/cenapi_estado_by_year: sql/views/cenapi_estado_by_year.sql db/views/estatales db/views/municipales
	$(call create_view)

.PHONY: db/views/cenapi_by_month
db/views/cenapi_by_month: sql/views/cenapi_by_month.sql db/views/estatales db/views/municipales
	$(call create_view)

.PHONY: db/views/cenapi_by_year
db/views/cenapi_by_year: sql/views/cenapi_by_year.sql db/views/estatales db/views/municipales
	$(call create_view)

.PHONY: db/views/census_estatales
db/views/census_estatales: sql/views/census_estatales.sql db/views/estatales db/views/municipales
	$(call create_view)

.PHONY: db/views/census_municipios
db/views/census_municipios: sql/views/census_municipios.sql db/processed/base_municipios_datos db/views/estatales db/views/municipales
	$(call create_view)

.PHONY: db/views/cenapi_audit
db/views/cenapi_audit: sql/views/cenapi_audit.sql db/extensions/hstore db/processed/cenapi ## Audit CENAPI data
	$(call create_view)


##@ Database structure

define create_extension
	@(psql -c "\dx $(subst db/extensions/,,$@)" | grep $(subst db/extensions/,,$@) > /dev/null 2>&1 && \
		echo "extension $(subst db/extensions/,,$@) exists") || \
	psql -v ON_ERROR_STOP=1 -qX1ec "CREATE EXTENSION $(subst db/extensions/,,$@)"
endef

define create_raw_table
	@(psql -c "\d raw.$(subst db/tables/,,$@)" > /dev/null 2>&1 && \
		echo "table raw.$(subst db/tables/,,$@) exists") || \
	psql -v ON_ERROR_STOP=1 -qX1ef $<
endef

define create_processed_table
	@(psql -c "\d processed.$(subst db/processed/,,$@)" > /dev/null 2>&1 && \
		echo "table processed.$(subst db/processed/,,$@) exists") || \
	psql -v ON_ERROR_STOP=1 -qX1ef $<
endef

define create_schema
	@(psql -c "\dn $(subst db/schemas/,,$@)" | grep $(subst db/schemas/,,$@) > /dev/null 2>&1 && \
	  echo "schema $(subst db/schemas/,,$@) exists") || \
	psql -v ON_ERROR_STOP=1 -qaX1ec "CREATE SCHEMA $(subst db/schemas/,,$@)"
endef

define load_raw_shapefile
	@(psql -c "\d raw.$(subst db/shapefiles/,,$@)" > /dev/null 2>&1 && \
	 echo "table raw.$(subst db/shapefiles/,,$@) exists")	|| \
	shp2pgsql $< raw.$(subst db/shapefiles/,,$@) | psql -v ON_ERROR_STOP=1 -q
endef

define load_raw_csv
	@(psql -Atc "select count(*) from raw.$(subst db/csv/,,$@)" | grep -v -w "0" > /dev/null 2>&1 && \
	 	echo "raw.$(subst db/csv/,,$@) is not empty") || \
	psql -v ON_ERROR_STOP=1 -qX1ec "\copy raw.$(subst db/csv/,,$@) from '$(CURDIR)/$<' with delimiter ',' csv header;"
endef

define create_function
	@(psql -c "\df $(subst db/functions/,,$@)" | grep $(subst db/functions/,,$@) > /dev/null 2>&1 && \
	 echo "function $(subst db/functions/,,$@) exists")	|| \
	 psql -v ON_ERROR_STOP=1 -qX1ef sql/functions/$(subst db/functions/,,$@).sql
endef

.PHONY: db
db: tunnel ## Create database
	@(psql -c "SELECT 1" > /dev/null 2>&1 && \
		echo "database $(PGDATABASE) exists") || \
	createdb -e $(PGDATABASE) -E UTF8 -T template0 --locale=en_US.UTF-8

.PHONY: db/extensions/%
db/extensions/%: db ## Create extension % (where % is 'hstore', 'postgis', etc)
	$(call create_extension)

.PHONY: db/vacuum
db/vacuum: # Vacuum db
	psql -v ON_ERROR_STOP=1 -qec "VACUUM ANALYZE;"

.PHONY: db/schemas
db/schemas: $(patsubst %, db/schemas/%, $(SCHEMAS)) ## Make all schemas

.PHONY: db/schemas/%
db/schemas/%: db # Create schema % (where % is 'raw', etc)
	$(call create_schema)

.PHONY: db/functions
db/functions: $(patsubst %, db/functions/%, $(FUNCTIONS)) ## Make all functions

.PHONY: db/functions/%
db/functions/%: db
	$(call create_function)

.PHONY: db/searchpath
db/searchpath: db/schemas # Set up (hardcoded) schema search path
	psql -v ON_ERROR_STOP=1 -qX1c "ALTER DATABASE $(PGDATABASE) SET search_path TO public,views,processed,raw;"

.PHONY: db/tables/%
db/tables/%: sql/tables/%.sql db/searchpath # Create table % from sql/tables/%.sql
	$(call create_raw_table)

.PHONY: db/shapefiles/%
db/shapefiles/%: data/shapefiles/%.shp db/searchpath db/extensions/postgis # Load table % from data/shapefiles/%.shp
	$(call load_raw_shapefile)

.PHONY: db/csv/%
db/csv/%: data/processed/%.csv db/tables/% # Load table % from data/downloads/%.csv
	$(call load_raw_csv)

.PHONY: db/processed/%
db/processed/%: sql/processed/%.sql db/functions db/schemas # Make table cleaned and processed tables
	$(call create_processed_table)

.PHONY: dropschema/%
dropschema/%: # @TODO wrap in detection
	psql -v ON_ERROR_STOP=1 -qX1c "DROP SCHEMA IF EXISTS $* CASCADE;"

.PHONY: dropdb
dropdb: ## Drop database
	dropdb --if-exists -e $(PGDATABASE)


##@ Source data

.PHONY: download/shapefiles
download/shapefiles: data/downloads/marcos_geoestadicos_2017.zip ## Download shapefiles

.PHONY: download/gdrive
download/gdrive: $(patsubst %, data/downloads/%.csv, $(DATAFILES)) ## Download all Drive files

data/downloads/base_municipios_final_datos_01.rar:
	curl -o $@ http://www.conapo.gob.mx/work/models/CONAPO/Datos_Abiertos/Proyecciones2018/base_municipios_final_datos_01.rar

data/downloads/base_municipios_final_datos_01.csv: data/downloads/base_municipios_final_datos_01.rar
	unrar e $< $(dir $@) && touch $@

data/downloads/base_municipios_final_datos_02.rar:
	curl -o $@ http://www.conapo.gob.mx/work/models/CONAPO/Datos_Abiertos/Proyecciones2018/base_municipios_final_datos_02.rar

data/downloads/base_municipios_final_datos_02.csv: data/downloads/base_municipios_final_datos_02.rar
	unrar e $< $(dir $@) && touch $@

data/downloads/base_municipios_datos.csv: data/downloads/base_municipios_final_datos_01.csv data/downloads/base_municipios_final_datos_02.csv 
	xsv cat rows $^ > $@


data/downloads/marcos_geoestadicos_2017.zip: # Download INEGI shapefiles (geostatistical shapes)
	curl -o $@ http://internet.contenidos.inegi.org.mx/contenidos/Productos/prod_serv/contenidos/espanol/bvinegi/productos/geografia/marcogeo/889463142683_s.zip

$(INEGI_FILES): data/downloads/marcos_geoestadicos_2017.zip # Unzip INEGI shapefiles (see Makefile.vars for definition)
	unzip -j -o $< -d data/shapefiles && touch $(INEGI_FILES)

data/downloads/%.csv: secrets/rclone.conf # Download %.csv from Google Drive
	rclone --config $< copy mapadespariciones:$(@F) $(@D) && touch $@


##@ Process data

.PRECIOUS: data/exports/%.csv
data/exports/%.csv: db/views/%
	psql -v ON_ERROR_STOP=1 -qX1c "\copy (select * from $*) to '$(CURDIR)/$@' with (delimiter ',', format csv, header);"

.PRECIOUS: data/processed/%.csv
data/processed/%.csv: data/downloads/%.csv # Convert encoding
	iconv -f iso-8859-1 -t utf-8 $< > $@

.PRECIOUS: data/stats/%.csv
data/stats/%.csv: data/downloads/%.csv # Get column stats and metadata with xsv
	xsv stats $< > $@

.PRECIOUS: sql/tables/%.sql
sql/tables/%.sql: data/stats/%.csv # Parse column stats into SQL schema for import
	$(PIPENV) python processors/schema.py $< $@

##@ Exports

MAPVIEWS = municipales municipales_summary municipales_summary_ctr cenapi_distributed estatales

.PRECIOUS: data/geojson/%.json
data/geojson/%.json: # db/views/% ## Build geojson file from a view
	ogr2ogr -f GeoJSON $@ PG:$(GDALSTRING) -sql "select * from $*"

.PRECIOUS: data/mbtiles/%.mbtiles
data/mbtiles/%.mbtiles: data/geojson/%.json
	tippecanoe --generate-ids -Z0 -z13 -S 5 --hilbert --detect-shared-borders --drop-smallest-as-needed -o $@ -f $<

.PRECIOUS: data/mbtiles/municipales_summary.mbtiles
data/mbtiles/municipales_summary.mbtiles: data/geojson/municipales_summary.json
	tippecanoe --generate-ids -Z0 -z13 -S 5 --hilbert --detect-shared-borders -o $@ -f $<

.PRECIOUS: data/mbtiles/cenapi_distributed.mbtiles
data/mbtiles/cenapi_distributed.mbtiles: data/geojson/cenapi_distributed.json
	tippecanoe --generate-ids -Z0 -z13 -r 1.4 -o $@ -f $<

.PRECIOUS: data/mbtiles/desapariciones.mbtiles
data/mbtiles/desapariciones.mbtiles: $(patsubst %, data/mbtiles/%.mbtiles, $(MAPVIEWS))
	tile-join -o $@ $^

.PHONY: mapbox
mapbox: data/mbtiles/desapariciones.mbtiles
	mapbox upload $(MAPBOX_USER).$(MAPBOX_TILESET_ID) $<

.PHONY: mbview
mbview: data/mbtiles/desapariciones.mbtiles
	MAPBOX_ACCESS_TOKEN=$(MAPBOX_PUBLIC_ACCESS_TOKEN) mbview $^


##@ Frontend data

site/src/map-styles/style.json: ## Get map style from mapbox
	curl "https://api.mapbox.com/styles/v1/$(MAPBOX_USER)/$(MAPBOX_STYLE_ID)?access_token=$(MAPBOX_ACCESS_TOKEN)" | jq > $@


##@ Utilities

tunnel: $(BASTION_KEY)
	ssh -i $(BASTION_KEY) -M -S $@ -fnNT -L localhost:5001:$(BASTION_DB):5432 $(BASTION_HOST)

.PHONY: tunnel/drop
tunnel/drop: tunnel
	ssh -i $(BASTION_KEY) -S $< -O exit $(BASTION_HOST)
	
.PHONY: develop
develop: load  ## Run development server
	grunt --base site develop

.PHONY: dbshell
dbshell: db ## Log in to database configured in .env.
	psql

.PHONY: install
install: install/npm install/pipenv install/hasura-cli ## Install project Node and Python dependencies

.PHONY: install/npm
install/npm: # Install from NPM
	npm install

.PHONY: install/pipenv
install/pipenv: # Install pipenv
	pipenv install

.PHONY: install/hasura-cli
install/hasura-cli: # Install hasura cli
	curl -L https://github.com/hasura/graphql-engine/raw/master/cli/get.sh | bash

.PHONY: clean/data
clean/data: $(patsubst %, rm/%, $(DATA_DIRECTORIES)) ## Remove all data files

#rm -rf sql/tables/*

.PHONY: clean/downloads
clean/downloads: $(patsubst %, rm/%, $(DOWNLOAD_DIRECTORIES)) ## Remove all downloads

.PHONY: rm/%
rm/%: # Remove data/% where % is a directory name
	rm -rf data/$*/*
