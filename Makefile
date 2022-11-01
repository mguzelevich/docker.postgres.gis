.PHONY: run test clean

exec_root = $(shell pwd)
ts = $(shell date +%Y%m%d_%H%M%S)
short_ts = $(shell date +%Y%m%d)

build-gis-docker:
	docker-compose -f stack.yml build builder

run-db:
	docker-compose -f stack.yml up

select:
	docker-compose -f stack.yml run --rm db sh -c 'echo "CREATE EXTENSION h3; SELECT h3_lat_lng_to_cell(POINT('37.3615593,-122.0553238'), 5);" | psql "host=db port=5432 user=postgres password=postgres"'

psql:
	docker-compose -f stack.yml run -it --rm db psql "host=db port=5432 user=postgres password=postgres"
