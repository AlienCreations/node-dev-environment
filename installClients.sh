#!/usr/bin/env bash

set -a
. exports/clients
set +a

source './installFromGit.sh'

let githubUser

onlyClients=()

while getopts "u:s:" opt; do
  case ${opt} in
    u)
      echo "Using github user $OPTARG" >&2
      githubUser=$OPTARG;
      ;;
    s)
      echo "Using client $OPTARG" >&2
      onlyClients+=($OPTARG);
      ;;
  esac
done
shift $((OPTIND -1))

for opt in "$@"; do
  if [[ "$opt" != "-s" ]]; then
    echo "Using client $opt" >&2
    onlyClients+=($opt)
  fi
done

onlyClientsCount=${#onlyClients}

if [ ${onlyClientsCount} -eq 0 ]; then
  CLIENT_ARRAY=${CLIENTS[@]}
else
  CLIENT_ARRAY=${onlyClients[@]}
fi

for client in ${CLIENT_ARRAY}
do
  installFromGit "${client}-web" "${githubUser}"
done
