#!/usr/bin/env bash

set -a
. exports/demo.env
. exports/platforms
set +a

if [ "$#" -eq  "0" ]
  then
    SERVICE_ARRAY=${PLATFORMS[@]}
  else
    SERVICE_ARRAY="$@"
fi

# Ensure exposed exports here are JSON friendly for node
export WHITELIST=$(bash ./utils/generateWhitelistEnv.sh)
export PUBLIC_KEYS=$(bash ./utils/generatePublicKeysEnv.sh)
export PRIVATE_KEY=$(bash ./utils/generatePrivateKeyEnv.sh)
export SERVICES=$(bash ./utils/generateServicesEnv.sh)

for service in ${SERVICE_ARRAY[@]}
do
  export $(grep NODE_PORTS ../${service}-platform/run/env/demo/.env | xargs)

  for port in $(echo ${NODE_PORTS} | sed "s/,/ /g")
  do
    printf "ping ${service} check: http://platform.${service}-platform.test:${port}/ping\n"
    curl "http://platform.${service}-platform.test:${port}/ping" --insecure
    printf "\n"
  done
done

