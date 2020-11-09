#!/usr/bin/env bash

set -a
. exports/platforms
set +a

SERVICE_ARRAY=${PLATFORMS[@]}

export SERVICE_ARRAY && s=$(node << EOF
  const R = require('ramda');

  const makeKey = k => k + 'Platform';

  R.compose(
    a => process.stdout.write(a),
    JSON.stringify,
    R.append('lambda'),
    R.map(makeKey),
    R.split(' ')
  )(process.env.SERVICE_ARRAY);
EOF
)

printf "%s" "${s}"
