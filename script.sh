#!/bin/sh

export DOCKER_DIR=`pwd`
export DOCKER_BUILD_ARGS=  # Uses eval, when overriding escape whitespace: '--build-arg\ "FOO=BAR"'
export REGISTRY=registry.npohosting.nl # For deploying to openshift, this must be   REGISTRY: openshift-image-registry.apps.cluster.chp4.io. (See also maven_deploy_openshift)
export DOCKER_AUTH_CONFIG_FILE=$HOME/.docker/config-gitlab.json
export KANIKO_ARGS='--cache=false --cache-copy-layers=false'
export AS_LATEST='false'
export TRACE='false'

. /docker-build-setup.sh
. /kaniko-gitlab.sh

echo "Using build args $DOCKER_BUILD_ARGS"
setup_kaniko $DOCKER_AUTH_CONFIG_FILE
kaniko_execute
store_image_version