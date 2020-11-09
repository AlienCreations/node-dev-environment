#!/usr/bin/env bash

set -a
. ./exports/demo.env
set +a

if [ "$2" = "test" ]; then
  MYSQL_VOLUME_MOUNT=${MYSQL_VOLUME_NULL}
else
  MYSQL_TMPFS=${MYSQL_VOLUME_NULL}
fi

KILL_DOCKER() {
  docker-compose down
  rm -rf ./tmp
}

if [ "$1" = "up" ]; then
  KILL_DOCKER
  docker-compose up
else
  KILL_DOCKER
fi
