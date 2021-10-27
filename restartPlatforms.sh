#!/usr/bin/env bash

set -a
. exports/demo.env
. exports/platforms
set +a

if [ "$#" -eq  "0" ]
  then
    PLATFORM_ARRAY=(${PLATFORMS[@]})
  else
    PLATFORM_ARRAY=("$@")
fi

# Ensure exposed exports here are JSON friendly for node
export WHITELIST=$(bash ./utils/generateWhitelistEnv.sh)
export PUBLIC_KEYS=$(bash ./utils/generatePublicKeysEnv.sh)
export PRIVATE_KEY=$(bash ./utils/generatePrivateKeyEnv.sh)
export PLATFORMS=$(bash ./utils/generateServicesEnv.sh)

for platform in ${PLATFORM_ARRAY[@]}
do
  _platform=$(export platform && echo $(node -e 'console.log(process.env.platform.replace(/[\w]([A-Z])/g, m => m[0] + "-" + m[1]).toLowerCase())'))

  export $(grep NODE_PORTS ../${_platform}-platform/run/env/demo/.env | xargs)

  for port in $(echo ${NODE_PORTS} | sed "s/,/ /g")
  do
    lsof -ti tcp:${port} | xargs kill
  done

  pushd ../${_platform}-platform
  bash ./run/env/demo/restart.sh | sed 's/^/['"${_platform}"'] /' &
  popd
done
