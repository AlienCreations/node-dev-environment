#!/usr/bin/env bash

set -a
. exports/platforms
set +a

PLATFORM_ARRAY=${PLATFORM_SERVICES[@]}

export PLATFORM_ARRAY && s=$(node << EOF
  const R = require('ramda');

  const makeKey = k => k + 'Platform';

  R.compose(
    a => process.stdout.write(a),
    JSON.stringify,
    R.append('lambda'),
    R.map(makeKey),
    R.split(' ')
  )(process.env.PLATFORM_ARRAY);
EOF
)

printf "%s" "${s}"
