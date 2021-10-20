#!/bin/bash

set -o allexport
source .env

if ! PGPASSWORD=${DATASOURCE_PASSWORD} psql -h localhost -U ${DATASOURCE_USERNAME} -lqt | cut -d \| -f 1 | grep -qw user-service ; then
  PGPASSWORD=${DATASOURCE_PASSWORD} psql -h localhost -U ${DATASOURCE_USERNAME} -c 'create database user-service;'
fi

if ! PGPASSWORD=${DATASOURCE_PASSWORD} psql -h localhost -U ${DATASOURCE_USERNAME} -lqt | cut -d \| -f 1 | grep -qw admin-service ; then
  PGPASSWORD=${DATASOURCE_PASSWORD} psql -h localhost -U ${DATASOURCE_USERNAME} -c 'create database admin-service;'
fi

docker-compose -f docker-compose.dev.yml up -d

set +o allexport