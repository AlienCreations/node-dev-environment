#!/usr/bin/env bash

set -a
. exports/platforms
set +a

source './installFromGit.sh'

let githubUser
let githubOrganization

onlyPlatforms=()

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
      echo "Using platform $OPTARG" >&2
      onlyPlatforms+=($OPTARG);
      ;;
  esac
done
shift $((OPTIND -1))

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

for opt in "$@"; do
  if [[ "$opt" != "-s" ]]; then
    echo "Using platform $opt" >&2
    onlyPlatforms+=($opt)
  fi
done

onlyPlatformsCount=${#onlyPlatforms}

if [ ${onlyPlatformsCount} -eq 0 ]; then
  PLATFORM_ARRAY=${PLATFORM_SERVICES[@]}
else
  PLATFORM_ARRAY=${onlyPlatforms[@]}
fi

for platform in ${PLATFORM_ARRAY}
do
  _platform=$(export platform && echo $(node -e 'console.log(process.env.platform.replace(/[\w]([A-Z])/g, m => m[0] + "-" + m[1]).toLowerCase())'))

  installFromGit  "${PROJECT_PREFIX}${_platform}-platform" "${githubUser}" "${githubOrganization}"
done
