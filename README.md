# docker with postgres + postgis + h3

## build

```
$ make build-gis-docker
```

## run & init database

```
$ make run-gis-server init-db
```

## test

```
$ make psql-exec sql="CREATE EXTENSION h3; SELECT h3_lat_lng_to_cell(POINT('37.3615593,-122.0553238'), 5);"
```
