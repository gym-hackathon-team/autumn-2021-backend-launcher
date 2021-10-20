#!/bin/bash

set -o allexport
source .env

docker-compose -f docker-compose.dev.yml up -d

set +o allexport