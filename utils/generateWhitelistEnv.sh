#!/usr/bin/env bash

set -a
. exports/platforms
set +a

SERVICE_ARRAY=${PLATFORMS[@]}

export SERVICE_ARRAY && w=$(node << EOF
  const R = require('ramda');

  const makeKey = k => k + 'Platform';

  R.compose(
    a => process.stdout.write(a),
    JSON.stringify,
    R.mergeAll,
    arr => R.map( k => ({ [k] : R.without([k], arr) }))(arr),
    R.append('lambda'),
    R.map(makeKey),
    R.split(' ')
  )(process.env.SERVICE_ARRAY);
EOF
)

printf "%s" "${w}"
