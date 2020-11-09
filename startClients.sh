#!/usr/bin/env bash

set -a
. exports/demo.env
. exports/clients
set +a

if [ "$#" -eq  "0" ]
  then
    CLIENT_ARRAY=(${CLIENTS[@]})
  else
    CLIENT_ARRAY=("$@")
fi

# remove duplicate items
CLIENT_ARRAY=($(echo "${CLIENT_ARRAY[@]}" | tr ' ' '\n' | sort -u | tr '\n' ' '))

for client_i in "${!CLIENT_ARRAY[@]}";
do
  client=${CLIENT_ARRAY[client_i]}
  ((port))

  for _client_i in "${!CLIENTS[@]}";
  do
    if [ "${CLIENTS[_client_i]}" = "${client}" ]
      then
        port=${CLIENT_PORTS[_client_i]}
    fi
  done

  lsof -ti tcp:"${port}" | xargs kill
  pushd "../${client}-web" || return
  export PORT=${port} && yarn start | sed 's/^/['"${client}:${port}"'] /' &
  popd || return
done
