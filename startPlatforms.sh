#!/usr/bin/env bash

set -a
. exports/demo.env
. exports/platforms
set +a

if [ "$#" -eq  "0" ]
  then
    PLATFORM_ARRAY=(${PLATFORM_SERVICES[@]})
  else
    PLATFORM_ARRAY=("$@")
fi

# Ensure exposed exports here are JSON friendly for node
export WHITELIST=$(bash ./utils/generateWhitelistEnv.sh)
export PRIVATE_KEY=$(bash ./utils/generatePrivateKeyEnv.sh)
export PUBLIC_KEYS=$(bash ./utils/generatePublicKeysEnv.sh)
export PLATFORMS=$(bash ./utils/generatePlatformsEnv.sh)

for platform in ${PLATFORM_ARRAY[@]}
do
  _platform=$(export platform && echo $(node -e 'console.log(process.env.platform.replace(/[\w]([A-Z])/g, m => m[0] + "-" + m[1]).toLowerCase())'))

  # Kill running applications first
  export $(grep NODE_PORTS ../${PROJECT_PREFIX}${_platform}-platform/run/env/demo/.env | xargs)

  for port in $(echo ${NODE_PORTS} | sed "s/,/ /g")
  do
    lsof -ti tcp:${port} | xargs kill
  done

  pushd ../${PROJECT_PREFIX}${_platform}-platform
  touch ./.env
  bash ./run/env/demo/run.sh | sed 's/^/['"${_platform}"'] /' &
  popd
done

