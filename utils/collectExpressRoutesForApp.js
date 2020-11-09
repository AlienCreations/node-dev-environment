'use strict';

const R = require('ramda');

const split = a => {
  if (typeof a === 'string') {
    return a.split('/');
  } else if (a.fast_slash) {
    return '';
  } else {
    const match = a.toString()
      .replace('\\/?', '')
      .replace('(?=\\/|$)', '$')
      .match(/^\/\^((?:\\[.*+?^${}()|[\]\\\/]|[^.*+?^${}()|[\]\\\/])*)\$\//);
    return match
      ? match[1].replace(/\\(.)/g, '$1').split('/')
      : '<complex:' + a.toString() + '>';
  }
};

const collectExpressRoutesForApp = app => {
  let routes = [];

  function print (path, layer) {
    if (layer.route) {
      layer.route.stack.forEach(print.bind(null, path.concat(split(layer.route.path))))
    } else if (layer.name === 'router' && layer.handle.stack) {
      layer.handle.stack.forEach(print.bind(null, path.concat(split(layer.regexp))))
    } else if (layer.method) {
      routes.push(`${layer.method.toUpperCase()} /${path.concat(split(layer.regexp)).filter(Boolean).join('/')}`);
    }
  }

  app._router.stack.forEach(print.bind(null, []));

  return R.compose(R.sortBy(R.identity), R.uniq)(routes);
};

module.exports = collectExpressRoutesForApp;
