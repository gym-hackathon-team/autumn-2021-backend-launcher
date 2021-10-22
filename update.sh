#!/bin/bash

cd update || exit 1
sed 'N;s/build:\n.*//;P;D' docker-compose.dev.yml > ../docker-compose.dev.yml || exit 2

set -o allexport
source ../.env
sed 's/\(.*\)=/\1=${\1}/' .env.example | envsubst > ../.env
set +o allexport