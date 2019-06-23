# Disappearances

Rig to process and publish project materials related to public data about disappearances.

The quickest way to get up and running is to clone this repository and run `make help`.

## Requirements

* GNU Make
* NodeJS
* PostgreSQL
* PostGIS
* GDAL
* xsv
* rclone

You'll need to either:

* Get a set of configuration files to put in the `secrets` directory and to populate the `.env` file from one of the developers.
* Configure the project yourself (currently undocumented).

## Setup

```
make install
```

## Running

```
make all
```

## Database structure

The structure of the database is novel and perhaps even too complex, but we're trying it!

The database uses PostgreSQL schemas to separate untransformed data from transformed data.
