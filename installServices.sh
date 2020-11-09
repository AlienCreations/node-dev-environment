#!/usr/bin/env bash

set -a
. exports/platforms
set +a

source './installFromGit.sh'

let githubUser

onlyServices=()

while getopts "u:s:" opt; do
  case ${opt} in
    u)
      echo "Using github user $OPTARG" >&2
      githubUser=$OPTARG;
      ;;
    s)
      echo "Using service $OPTARG" >&2
      onlyServices+=($OPTARG);
      ;;
  esac
done
shift $((OPTIND -1))

for opt in "$@"; do
  if [[ "$opt" != "-s" ]]; then
    echo "Using service $opt" >&2
    onlyServices+=($opt)
  fi
done

onlyServicesCount=${#onlyServices}

if [ ${onlyServicesCount} -eq 0 ]; then
  SERVICE_ARRAY=${PLATFORMS[@]}
else
  SERVICE_ARRAY=${onlyServices[@]}
fi

for service in ${SERVICE_ARRAY}
do
  _service=$(export service && echo $(node -e 'console.log(process.env.service.replace(/[\w]([A-Z])/g, m => m[0] + "-" + m[1]).toLowerCase())'))

  installFromGit  "${_service}-platform" "${githubUser}"
done
