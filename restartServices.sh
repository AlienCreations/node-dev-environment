#!/usr/bin/env bash

set -a
. exports/demo.env
. exports/platforms
set +a

if [ "$#" -eq  "0" ]
  then
    SERVICE_ARRAY=(${PLATFORMS[@]})
  else
    SERVICE_ARRAY=("$@")
fi

# Ensure exposed exports here are JSON friendly for node
export WHITELIST=$(bash ./utils/generateWhitelistEnv.sh)
export PUBLIC_KEYS=$(bash ./utils/generatePublicKeysEnv.sh)
export PRIVATE_KEY=$(bash ./utils/generatePrivateKeyEnv.sh)
export SERVICES=$(bash ./utils/generateServicesEnv.sh)

for service in ${SERVICE_ARRAY[@]}
do
  _service=$(export service && echo $(node -e 'console.log(process.env.service.replace(/[\w]([A-Z])/g, m => m[0] + "-" + m[1]).toLowerCase())'))

  export $(grep NODE_PORTS ../${_service}-platform/run/env/demo/.env | xargs)

  for port in $(echo ${NODE_PORTS} | sed "s/,/ /g")
  do
    lsof -ti tcp:${port} | xargs kill
  done

  pushd ../${_service}-platform
  bash ./run/env/demo/restart.sh | sed 's/^/['"${_service}"'] /' &
  popd
done