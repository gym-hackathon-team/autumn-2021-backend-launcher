#!/bin/bash

if [ ! -d artifacts ] ; then
  mkdir artifacts || exit 1
fi

if [ ! -d ssl ] ; then
  mkdir ssl || exit 2
fi

if [ ! -e ssl/ssl.crt ] || [ ! -e ssl/ssl.key ] ; then
  rm -f ssl/ssl.crt ssl/ssl.key
  openssl req -newkey rsa:4096 -x509 -sha256 -days 3650 -nodes -out ssl/ssl.crt -keyout ssl/ssl.key -batch
fi

if [ ! -e ssl/dhparam.pem ] ; then
  openssl dhparam -out ssl/dhparam.pem 2048
fi

docker stop nginx
docker rm nginx
docker run -v $(pwd)/nginx.conf:/etc/nginx/nginx.conf:ro -v $(pwd)/ssl:/ssl:ro -v $(pwd)/artifacts:/artifacts:ro -p "443:443" -d --name nginx nginx || exit 3

docker-compose -f docker-compose.dev.yml up -d database || exit 4
sleep 5

set -o allexport
source .env

if ! PGPASSWORD=${DATASOURCE_PASSWORD} psql -h localhost -U ${DATASOURCE_USERNAME} -lqt | cut -d \| -f 1 | grep -qw user-service ; then
  PGPASSWORD=${DATASOURCE_PASSWORD} psql -h localhost -U ${DATASOURCE_USERNAME} -c 'create database "user-service";' || exit 5
fi

if ! PGPASSWORD=${DATASOURCE_PASSWORD} psql -h localhost -U ${DATASOURCE_USERNAME} -lqt | cut -d \| -f 1 | grep -qw admin-service ; then
  PGPASSWORD=${DATASOURCE_PASSWORD} psql -h localhost -U ${DATASOURCE_USERNAME} -c 'create database "admin-service";' || exit 6
fi

set +o allexport

docker-compose -f docker-compose.dev.yml up -d || exit 7