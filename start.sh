#!/bin/bash

docker-compose -f docker-compose.dev.yml up -d database || return 1
sleep 5

set -o allexport
source .env

if ! PGPASSWORD=${DATASOURCE_PASSWORD} psql -h localhost -U ${DATASOURCE_USERNAME} -lqt | cut -d \| -f 1 | grep -qw user-service ; then
  PGPASSWORD=${DATASOURCE_PASSWORD} psql -h localhost -U ${DATASOURCE_USERNAME} -c 'create database "user-service";' || return 2
fi

if ! PGPASSWORD=${DATASOURCE_PASSWORD} psql -h localhost -U ${DATASOURCE_USERNAME} -lqt | cut -d \| -f 1 | grep -qw admin-service ; then
  PGPASSWORD=${DATASOURCE_PASSWORD} psql -h localhost -U ${DATASOURCE_USERNAME} -c 'create database "admin-service";' || return 3
fi

set +o allexport

docker-compose -f docker-compose.dev.yml up -d || return 4