## Using this repo
If you have not already done so, scroll down to the **Dependencies** section below and make sure you have all the system dependencies installed.

This is meant to be run from within a folder containing the other `platform` microservices. For example:

```
- my-project
  |
  -- software
     |
      -- node-dev-environment
         |
          -- platforms
             |
              -- auth-platform
              -- product-platform
              -- ...
          -- clients
             |
              -- my-project-web
              -- ...
```

You don't need to clone those repos first as the script below will do that.

## Step 1
Log into NPM if you haven't done so already and update your `.npmrc` file to include `@aliencreations:registry=https://npm.pkg.github.com/`


## Step 2
##### Install all the project apps

Specify your user for http auth, install clients and platforms separately

```
$ yarn install-clients -u <github username>
```

```
$ yarn install-platforms -u <github username>
```

Run this command to 
 - pull down the supported `platform` projects (*-platform) and install their dependencies in folders matching the github repo names.
 - pull down the supported `client` projects (*-web) and install their dependencies in folders matching the github repo names.
 
The list of supported platforms for this project can be found in `./exports/platforms`. 
The list of supported clients for this project can be found in `./exports/clients`. 

As we create new clients and clients, we will need to add them to these lists. 

We also pre-define ports from 3000 onward for the clients in _this_ repo. 

Services specify their own ports in their own repos. 

If you are fine with the default ports, this should all work fine.

To manually specify a particular platform/client or group of platforms/clients to install, just add a list of one or more platform names. An example : 
_NOTE_: This is a change from previous versions which required `-s` before each platform name. This
version can accept `-s` but does not require it.

Service aliases are `[alias]-platform` to match github repository naming conventions:
Here are some examples; any stored procedures you have which may include the `-s` are still supported
```
$  yarn install-platforms -u <github username> auth i18n # The preferred method
$  yarn install-platforms -u <github username> -s auth i18n
$  yarn install-platforms -u <github username> -s auth -s i18n
```

Client aliases are `[alias]-web` to match github repository naming conventions; similar changes as
listed above for install-platforms: `-s` not required but supported.
```
$ yarn install-clients -u <github username> app1 app2
```

## Step 3
###### Once you install everything, start the system. There are two parts: docker infrastructure, and the suite of apps: 

```
$ yarn boot-up
```
Run this command to spin up the Docker infrastructure (mysql, s3, etc) which will support _all_ the platform platforms.  
*The platforms themselves are not started with this command.*

If you'd like to use this to run unit tests on multiple platforms, you likely want to mount MySQL to memory (tmpfs). In this case, 
simply add the `test` flag: 

```
$ yarn boot-up test
```

To bring down the platforms, execute:
```
$ yarn boot-down
```
This is important because Docker will hold onto these containers and images and they take up memory on your computer.


## Step 4 (IN A NEW TERMINAL WINDOW)
##### Start the apps

Option 1: This will start _all_ platform apis and _all_ web clients:
```
$ yarn start
```

Option 2: This will start _all_ platform apis only:
```
$ yarn start-platforms
```

Option 3: This will start _all_ clients only:
```
$ yarn start-clients
```

Options 2 and 3 accept optional aliases. Example, only start up i18n and media platforms, and order tunnel:
```
$ yarn start-platforms auth i18n
$ yarn start-clients app1
```


## Testing connectivity
This will try to hit a `ping` endpoint for all the platforms. Success will be if you receive a `pong` response.
```
$ yarn test
```

## Restarting
Platform apis often do a lot of database and binary asset seeding to Docker that can be time-consuming to stop and start 
again while working and testing changes. If you are working on a platform and simply want to restart Express without 
rebuilding the database and asset seeds, you can use the restart command: 
```
$ yarn restart-platforms
``` 

or one/many specified: 
```
$ yarn restart-platforms i18n media
``` 

#### Restarting client apps
You can also restart the client apps but usually the workflow would be that you use the `node-dev-environment` to spin up 
all the _other_ client apps that run in parallel to the one you are working on. In a new terminal or in your IDE you could 
spin up that one client app (make sure ports don't conflict) and then use webpack's live-reload which may be much easier.
```
$ yarn restart-clients
``` 

or one/many specified: 
```
$ yarn restart-clients app1 app2
``` 

## Kill command
In an emergency if things go haywire, stop all platforms and clients. In a new terminal:
```
killall node
```
or
```
pkill -9 node
```

## Dependencies
These are the system dependencies required to run all the node.js microplatforms.

### DNS
EITHER : Add the following to your `/etc/hosts` file:
```
127.0.0.1 platform.auth-platform.test
127.0.0.1 platform.media-platform.test
127.0.0.1 platform.product-platform.test
127.0.0.1 platform.i18n-platform.test
127.0.0.1 platform.customer-platform.test
127.0.0.1 platform.message-platform.test
... and so on for each domain
```

OR : Use dnsmasq https://www.stevenrombauts.be/2018/01/use-dnsmasq-instead-of-etc-hosts/

### NodeJS
Make sure [Node is installed](https://nodejs.org/en/download/). These apps require at least node version 10.x.

Make sure you are the owner of the folder in which NPM needs to install any global dependencies: ([article with more information](http://howtonode.org/introduction-to-npm)).

On OSX/Unix, this command should work:
```
$ sudo chown -R $USER /usr/local
```  
* note: Depending on how much is in that directory, that command may take a bit of time to run.

### Install the Node dependencies
### Yarn
Install [Yarn](https://yarnpkg.com/lang/en/docs/install/) and use it instead of npm to ensure consistent builds.   
On OSX, you can easily install Yarn with Homebrew:

```bash
brew update
brew install yarn
```

### XCode
1.  Install Xcode from the Mac Store
1.  After running `yarn install` on one of the frontend apps like SNR Trak, if you get a node `gyp` error, try executing `xcode-select --install` and if that still doesn't work, run
```
$ xcode-select -print-path
/Library/Developer/CommandLineTools
$ sudo rm -rf /Library/Developer/CommandLineTools
xcode-select --install
```
