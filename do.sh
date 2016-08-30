#!/bin/bash

# run commands on a custom image

if [ -f VERSION ]; then
  # Output colors
  NORMAL="\\033[0;39m"
  RED="\\033[1;31m"
  BLUE="\\033[1;34m"

  VERSION=$(cat VERSION)
  FOLDER_PATH='/home/yuri/workspace/js'
  NAME=$(basename "$PWD")
  VOLUMES=(
    $FOLDER_PATH/yebo-ember/packages/auth:/packages/node_modules/yebo-ember-auth
    $FOLDER_PATH/yebo-ember/packages/checkouts:/packages/node_modules/yebo-ember-checkouts
    $FOLDER_PATH/yebo-ember/packages/core:/packages/node_modules/yebo-ember-core
    $FOLDER_PATH/yebo-ember/packages/storefront:/packages/node_modules/yebo-ember-storefront
    $FOLDER_PATH/yebo_sdk:/packages/bower_components/yebo_sdk
  )
else
  echo "Could not find a VERSION file"
fi

bootstrap() {
  docker rm -f node_modules
  docker rm -f bower_components
  docker rm -f cache
  docker run --name node_modules -d yurifl/node_modules
  docker run --name bower_components -d yurifl/bower_components
  docker run --name cache -d -e PORT=8080 -p 8080:80 tswicegood/npm-cache
}

up() {
  docker run -ti --rm \
    -e EMBER_ENV=development \
    -p 4200:4200 -p 49152:49152 \
    -v $(pwd):/usr/src/app \
    $(printf '\t-v %s\n' "${VOLUMES[@]}") \
    --volumes-from "node_modules" \
    --volumes-from "bower_components" \
    yurifl/work up
}

run() {
  docker run -ti --rm \
    -e EMBER_ENV=development \
    -p 4200:4200 -p 49152:49152 \
    -v $(pwd):/usr/src/app \
    -v $HOME/.bin:/bins \
    $(printf '\t-v %s\n' "${VOLUMES[@]}") \
    --volumes-from "node_modules" \
    --volumes-from "bower_components" \
    yurifl/work "$@"
}

build-dev() {
  docker run -ti --rm \
    -v $(pwd):/usr/src/app \
    $(printf '\t-v %s\n' "${VOLUMES[@]}") \
    --volumes-from "node_modules" \
    --volumes-from "bower_components" \
    yurifl/work build-dev
}

build-full() {
  docker run -ti --rm \
    -v $(pwd):/usr/src/app \
    --volumes-from "node_modules" \
    --volumes-from "bower_components" \
    yurifl/work build-full

  docker build -t $NAME .
}

build() {
  docker run -ti --rm \
    -v $(pwd):/usr/src/app \
    --volumes-from "node_modules" \
    --volumes-from "bower_components" \
    yurifl/work build

  docker build -t $NAME .
}

b() {
  docker build -t $NAME .
  docker rmi gcr.io/yebo-project/$NAME:v$VERSION
  docker tag $NAME gcr.io/yebo-project/$NAME:v$VERSION
  docker tag $NAME gcr.io/yebo-project/$NAME
}

remember() {
  echo 'do build'
  echo "docker tag $NAME gcr.io/yebo-project/$NAME:v$VERSION"
  echo "docker tag $NAME gcr.io/yebo-project/$NAME"
  echo "docker run --rm -ti -p 80:80 -p 443:443 gcr.io/yebo-project/$NAME:v$VERSION"
  echo "docker images | grep $NAME"
  echo "dg gcloud docker push gcr.io/yebo-project/$NAME:v$VERSION"
  echo "dg kubectl rolling-update $NAME --image=gcr.io/yebo-project/$NAME:v$VERSION"
  echo 'to staging:'
  echo "dg gcloud docker push gcr.io/yebo-project/$NAME"
  echo "dg kubectl rolling-update staging --image=gcr.io/yebo-project/$NAME"
}

tag() {
  docker rmi gcr.io/yebo-project/$NAME:v$VERSION
  docker tag $NAME gcr.io/yebo-project/$NAME:v$VERSION
  docker tag $NAME gcr.io/yebo-project/$NAME
  docker images | grep $NAME
  echo 'do prod'
  echo "dg gcloud docker push gcr.io/yebo-project/$NAME:v$VERSION"
  echo "dg kubectl rolling-update $NAME --image=gcr.io/yebo-project/$NAME:v$VERSION"
  echo 'to staging:'
  echo "dg gcloud docker push gcr.io/yebo-project/$NAME"
  echo "dg kubectl rolling-update staging --image=gcr.io/yebo-project/$NAME"
}

prod() {
  docker run --rm -ti -p 80:80 -p 443:443 gcr.io/yebo-project/$NAME:v$VERSION "$@"
}

help() {
  echo "-----------------------------------------------------------------------"
  echo "             Available commands (run in the SO)                       -"
  echo "-----------------------------------------------------------------------"
  echo -e -n "$BLUE"
  echo "   > bootstrap - Setup dependecies, create data containers and cache container"
  echo "   > run - Proxy for the container"
  echo "   > build-full - Build js and docker image"
  echo "   > build - Compile JS and Build container"
  echo "   > remember - Print usefull commands"
  echo "   > tag - Create tag based on current version"
  echo "   > prod - Run production container"
  echo "   > run help - To see commands availble inside container"
  echo -e -n "$NORMAL"
  echo "-----------------------------------------------------------------------"
}

$*
