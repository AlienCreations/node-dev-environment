#!/usr/bin/env bash

set -a
. exports/platforms
set +a

PLATFORM_ARRAY=${PLATFORM_SERVICES[@]}
SHARED_PUBLIC_KEY="-----BEGIN RSA PUBLIC KEY-----\nMIIBCgKCAQEAvzoCEC2rpSpJQaWZbUmlsDNwp83Jr4fi6KmBWIwnj1MZ6CUQ7rBa\nsuLI8AcfX5/10scSfQNCsTLV2tMKQaHuvyrVfwY0dINk+nkqB74QcT2oCCH9XduJ\njDuwWA4xLqAKuF96FsIes52opEM50W7/W7DZCKXkC8fFPFj6QF5ZzApDw2Qsu3yM\nRmr7/W9uWeaTwfPx24YdY7Ah+fdLy3KN40vXv9c4xiSafVvnx9BwYL7H1Q8NiK9L\nGEN6+JSWfgckQCs6UUBOXSZdreNN9zbQCwyzee7bOJqXUDAuLcFARzPw1EsZAyjV\ntGCKIQ0/btqK+jFunT2NBC8RItanDZpptQIDAQAB\n-----END RSA PUBLIC KEY-----"

export PLATFORM_ARRAY SHARED_PUBLIC_KEY && pks=$(node << EOF
  const R = require('ramda');

  const makeKey = k => k + 'Platform';

  R.compose(
    a => process.stdout.write(a),
    JSON.stringify,
    R.mergeAll,
    arr => R.map( k => ({ [k] : [process.env.SHARED_PUBLIC_KEY.replace(/\\\n/g, '\n')] }))(arr),
    R.append('lambda'),
    R.map(makeKey),
    R.split(' ')
  )(process.env.PLATFORM_ARRAY);
EOF
)

printf "%s" "${pks}"
