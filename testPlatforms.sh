#!/usr/bin/env bash

set -a
. exports/demo.env
. exports/platforms
set +a

if [ "$#" -eq  "0" ]
  then
    PLATFORM_ARRAY=${PLATFORMS[@]}
  else
    PLATFORM_ARRAY="$@"
fi

# Ensure exposed exports here are JSON friendly for node
export WHITELIST=$(bash ./utils/generateWhitelistEnv.sh)
export PUBLIC_KEYS=$(bash ./utils/generatePublicKeysEnv.sh)
export PRIVATE_KEY=$(bash ./utils/generatePrivateKeyEnv.sh)
export PLATFORMS=$(bash ./utils/generateServicesEnv.sh)

for platform in ${PLATFORM_ARRAY[@]}
do
  export $(grep NODE_PORTS ../${platform}-platform/run/env/demo/.env | xargs)

  for port in $(echo ${NODE_PORTS} | sed "s/,/ /g")
  do
    printf "ping ${platform} check: http://platform.${platform}-platform.test:${port}/ping\n"
    curl "http://platform.${platform}-platform.test:${port}/ping" --insecure
    printf "\n"
  done
done

