#!/bin/bash

# run commands on a custom image

if [ -f VERSION ]; then
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

setup() {
  docker rm -f node_modules
  docker rm -f bower_components
  docker rm -f cache
  docker run --name node_modules -d yurifl/node_modules
  docker run --name bower_components -d yurifl/bower_components
  docker run --name cache -d -e PORT=8080 -p 8080:80 tswicegood/npm-cache
}

run() {
  docker run -ti --rm \
    -p 4200:4200 -p 49152:49152 \
    -v $(pwd):/usr/src/app \
    $(printf '\t-v %s\n' "${VOLUMES[@]}") \
    --volumes-from "node_modules" \
    --volumes-from "bower_components" \
    yurifl/work "$@"
}

build-all() {
  docker run -ti --rm \
    -v $(pwd):/usr/src/app \
    --volumes-from "node_modules" \
    --volumes-from "bower_components" \
    yurifl/work build

  docker build -t $NAME .
}

build() {
  docker build -t $NAME .
}

remember() {
  echo 'do build-all'
  echo "docker tag $NAME gcr.io/yebo-project/$NAME:v$VERSION"
  echo "docker tag $NAME gcr.io/yebo-project/$NAME"
  echo "docker run --rm -ti -p 80:80 -p 443:443 gcr.io/yebo-project/$NAME:v$VERSION"
  echo "docker images | grep $NAME"
  echo "dg gcloud docker push gcr.io/yebo-project/$NAME:v$VERSION"
  echo "dg kubectl rolling-update rede-compras --image=gcr.io/yebo-project/$NAME:v$VERSION"
}

retag() {
  docker rmi gcr.io/yebo-project/$NAME:v$VERSION
  docker images | grep $NAME
}

tag() {
  docker tag $NAME gcr.io/yebo-project/$NAME:v$VERSION
  docker tag $NAME gcr.io/yebo-project/$NAME
  docker images | grep $NAME
}

prod() {
  docker run --rm -ti -p 80:80 -p 443:443 gcr.io/yebo-project/$NAME:v$VERSION
}

$*
