#!/usr/bin/env bash

# Be sure to run the docker script before auditing the routes
# $ yarn boot-up

set -a
. exports/demo.env
. exports/platforms
set +a

if [ "$#" -eq  "0" ]
  then
    PLATFORM_ARRAY=(${PLATFORM_SERVICES[@]})
  else
    PLATFORM_ARRAY=("$@")
fi

# Ensure exposed exports here are JSON friendly for node
export WHITELIST=$(bash ./utils/generateWhitelistEnv.sh)
export PRIVATE_KEY=$(bash ./utils/generatePrivateKeyEnv.sh)
export PUBLIC_KEYS=$(bash ./utils/generatePublicKeysEnv.sh)
export PLATFORMS=$(bash ./utils/generateServicesEnv.sh)

node << EOF
  const process       = require('process'),
        R             = require('ramda'),
        path          = require('path'),
        { paramCase } = require('change-case');


  const action = {
    GET    : 'Get',
    POST   : 'Create',
    PUT    : 'Update',
    DELETE : 'Delete'
  };

  const attemptTitle = method => route => {
    const routeParts = R.split('/')(route);
    if (method === 'GET') {
      if (routeParts.length > 3) {
        if (routeParts[6] && routeParts[6][0] === ':') {
          return routeParts[4] + ' by ' + routeParts[6].replace(':','');
        }
        if (routeParts[5]) {
          return routeParts[4] + ' ' + routeParts[5];
        }
        return routeParts[4] + 's';
      } else {
        return R.last(routeParts);
      }
    } else {
      if (routeParts.length > 3) {
        return routeParts[4] || routeParts[3];
      } else {
        return R.last(routeParts);
      }
    }
  };

  const devDir     = process.cwd();
  const routes     = {};
  let   resourceId = 1;
  let   resources  = ['1,NULL,NULL,All Resources and Methods,all-resources,*,*,2'];

  ${PLATFORMS}.map(_service => {
    const service = _service.replace(/[\w]([A-Z])/g, m => m[0] + "-" + m[1]).toLowerCase();

    console.log('Auditing ' + service + ' platform...');

    try {
      process.chdir('../' + service);
      require('dotenv').config({ path : './run/env/demo/.env' });

      const app     = require(path.resolve(__dirname, './server/core/core'));
      const _routes = require('../node-dev-environment/utils/collectExpressRoutesForApp')(app);

      routes[_service] = _routes;

      const _resources = R.compose(
        R.map(R.compose(
          ([ method, route ]) => {
            const title = action[method] + ' ' + attemptTitle(method)(route),
                  key   = paramCase(title);

            return ++resourceId + ',NULL,NULL,' + title + ',' + key + ',' + route + ',' + method + ',1';
          },
          R.split(' ')
        )),
        R.reject(R.either(
          R.equals('GET /'),
          R.equals('GET /views/*')
        ))
      )(_routes);

      resources.push(_resources);

      // Remove volatile env vars every loop
      delete process.env.NODE_AUTHENTICATOR_RELATIVE_CHECK_PERMISSION_PATH;

      process.chdir(devDir);
    } catch(e) {
      console.log('Error auditing ' + _service);
    }
  });

  console.log('');
  console.log('');
  console.log(routes);
  console.log('------');
  console.log('------');
  console.log('------');
  console.log('------');
  R.map(console.log, R.flatten(resources));
  process.exit(0);
EOF
