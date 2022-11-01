.PHONY: run test clean

exec_root = $(shell pwd)
ts = $(shell date +%Y%m%d_%H%M%S)
short_ts = $(shell date +%Y%m%d)

CONN_SERVER = host=pg port=5432 user=postgres password=postgres
CONN = dbname=gis ${CONN_SERVER}

USERNAME = <...>
MAPBOX_TOKEN = <...>

include Makefile.gis Makefile.mapbox

export WORKDIR=${exec_root}
### /tools

fmt:
	gofmt -w .
