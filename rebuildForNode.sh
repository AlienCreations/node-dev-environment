#!/usr/bin/env bash

### This script requires the gh cli
# $ brew install gh

set -a
. exports/platforms
. exports/clients
set +a

let githubUser

while getopts "u:" opt; do
  case ${opt} in
    u)
      echo "Using github user $OPTARG" >&2
      githubUser=$OPTARG;
      ;;
    \?)
      echo "Invalid option: -$OPTARG" >&2
      exit 1
      ;;
    :)
      echo "Option -$OPTARG requires an argument." >&2
      exit 1
      ;;
  esac
done

PLATFORM_ARRAY=${PLATFORMS[@]}
CLIENT_ARRAY=${CLIENTS[@]}

NODE_VERSION=$(node -v)
NPM_VERSION=$(npm -v)
GIT_BRANCH=CONNECT5-6007
COMMIT_MESSAGE="${GIT_BRANCH} - update code to support node ${NODE_VERSION}"

prepForRebuild() {
  git stash
  git checkout master
  git reset --hard origin/master
  git fetch origin
  git merge --ff-only origin/master
}

createPullRequest() {
  git branch -D "${GIT_BRANCH}"
  git push origin --delete "${GIT_BRANCH}"
  git checkout -b "${GIT_BRANCH}"
  git add .
  git commit -m "${COMMIT_MESSAGE}"
  git push origin "${GIT_BRANCH}" --force
  gh pr create --title "${COMMIT_MESSAGE}" --body ""
}

for platform in ${PLATFORM_ARRAY}
do
  _platform=$(export platform && echo $(node -e 'console.log(process.env.platform.replace(/[\w]([A-Z])/g, m => m[0] + "-" + m[1]).toLowerCase())'))

  pushd ../${_platform}-platform || exit

  prepForRebuild

  export _platform NODE_VERSION NPM_VERSION && node << EOF
    const fs   = require('fs'),
          path = require('path');

    const nodeVersion = process.env.NODE_VERSION.slice(1, Infinity),
          npmVersion  = process.env.NPM_VERSION;

    const rebuildDockerFile = () => {
      try {
        const dockerFilePath = path.resolve(__dirname, './Dockerfile');
        const dockerFile = fs.readFileSync(dockerFilePath, 'utf8');

        if (dockerFile) {
          console.log('Updating Dockerfile for Node ' + nodeVersion + ' on ' + process.env._platform + '-platform')
          fs.writeFileSync(dockerFilePath, dockerFile.replace(/node:([0-9]+.[0-9]+.[0-9]+)-stretch-slim/g, 'node:' + nodeVersion + '-stretch-slim'))
        }
      } catch (e) {}
    }

    const rebuildPackageJson = () => {
      try {
        const packageJsonPath = path.resolve(__dirname, './package.json');
        const packageJson     = fs.readFileSync(packageJsonPath, 'utf8');

        if (packageJson) {
          console.log('Updating package.json for Node ' + nodeVersion + ' and NPM version ' + npmVersion + ' on ' + process.env._platform + '-platform')
          const package = JSON.parse(packageJson);
          package.engines = {
            node : '^' + nodeVersion,
            npm  : '^' + npmVersion
          };
          fs.writeFileSync(packageJsonPath, JSON.stringify(package, null, 2));
        }
      } catch (e) {}
    }

    rebuildDockerFile();
    rebuildPackageJson();
EOF

  rm -rf node_modules
  rm yarn.lock

  yarn install --force
  yarn lint --fix
  yarn test

  createPullRequest

  popd || exit
done


for client in ${CLIENT_ARRAY}
do
  pushd ../${client}-web || exit

  prepForRebuild

  export client NODE_VERSION NPM_VERSION && node << EOF
    const fs   = require('fs'),
          path = require('path');

    const nodeVersion = process.env.NODE_VERSION.slice(1, Infinity),
          npmVersion  = process.env.NPM_VERSION;

    const rebuildPackageJson = () => {
      try {
        const packageJsonPath = path.resolve(__dirname, './package.json');
        const packageJson     = fs.readFileSync(packageJsonPath, 'utf8');

        if (packageJson) {
          console.log('Updating package.json for Node ' + nodeVersion + ' and NPM version ' + npmVersion + ' on ' + process.env.client + '-web')
          const package = JSON.parse(packageJson);
          package.engines = {
            node : '^' + nodeVersion,
            npm  : '^' + npmVersion
          };
          fs.writeFileSync(packageJsonPath, JSON.stringify(package, null, 2));
        }
      } catch (e) {}
    }

    rebuildPackageJson();
EOF

  rm -rf node_modules
  rm yarn.lock

  yarn install --force
  yarn lint --fix
  # yarn test

  createPullRequest

  popd || exit
done
