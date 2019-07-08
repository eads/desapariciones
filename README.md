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
* Mapbox CLI (brew install mapbox/cli/mapbox)

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

# Performance notes

We're comparing a few different approaches to building the frontend:

* Mapbox + Mapbox tiles to manage data
* DeckGL + GeoJSON to manage data
* With and without charting libraries

## Mapbox + Swipe library, no charting lib

This is a fairly minimalist configuration that corresponds with commit #481889ed.

* Overall: 89
* 1st contentful paint: 0.9s
* First meaningful paint: 0.9s
* Speed index:  3.3s
* 1st cpu idle: 4.5s
* time to interactive: 5.0s
* est input latency: 170ms
