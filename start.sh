#!/bin/bash

docker-compose -f docker-compose.dev.yml up -d database
sleep 5

set -o allexport
source .env

if ! PGPASSWORD=${DATASOURCE_PASSWORD} psql -h localhost -U ${DATASOURCE_USERNAME} -lqt | cut -d \| -f 1 | grep -qw user-service ; then
  PGPASSWORD=${DATASOURCE_PASSWORD} psql -h localhost -U ${DATASOURCE_USERNAME} -c 'create database "user-service";'
fi

if ! PGPASSWORD=${DATASOURCE_PASSWORD} psql -h localhost -U ${DATASOURCE_USERNAME} -lqt | cut -d \| -f 1 | grep -qw admin-service ; then
  PGPASSWORD=${DATASOURCE_PASSWORD} psql -h localhost -U ${DATASOURCE_USERNAME} -c 'create database "admin-service";'
fi

set +o allexport

docker-compose -f docker-compose.dev.yml up -d