#!/usr/bin/env bash

set -a
. exports/clients
set +a

source './installFromGit.sh'

let githubUser
let githubOrganization

onlyClients=()

while getopts "u:s:o:" opt; do
  case ${opt} in
    u)
      echo "Using github user $OPTARG" >&2
      githubUser=$OPTARG;
      ;;
    o)
      echo "Using github organization $OPTARG" >&2
      githubOrganization=$OPTARG;
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

if [[ -z "$githubUser" ]]; then
  echo "" 1>&2
  echo "Error: Missing github user. Please provide with -u flag" 1>&2
  echo "" 1>&2
  exit 1
fi

if [[ -z "$githubOrganization" ]]; then
  echo "" 1>&2
  echo "Error: Missing github organization. Please provide with -o flag" 1>&2
  echo "" 1>&2
  exit 1
fi

onlyClientsCount=${#onlyClients}

if [ ${onlyClientsCount} -eq 0 ]; then
  CLIENT_ARRAY=${CLIENTS[@]}
else
  CLIENT_ARRAY=${onlyClients[@]}
fi

for client in ${CLIENT_ARRAY}
do
  installFromGit "${client}-web" "${githubUser}" "${githubOrganization}"
done
