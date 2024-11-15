#!/bin/sh
echo "--------"
echo "Executing $0 in "
pwd
export DOCKER_DIR
DOCKER_DIR="$(pwd)"
export DOCKER_BUILD_ARGS=  # Uses eval, when overriding escape whitespace: '--build-arg\ "FOO=BAR"'
export REGISTRY="${REGISTRY:-registry.npohosting.nl}"
export DOCKER_AUTH_CONFIG_FILE=$HOME/.docker/config-gitlab.json
export KANIKO_ARGS='--cache=true --cache-copy-layers=true'
export AS_LATEST='false'
export TRACE='false'

echo Using registry ${REGISTRY}

. /kaniko-gitlab.sh

echo "Using build args $DOCKER_BUILD_ARGS"
setup_kaniko $DOCKER_AUTH_CONFIG_FILE
kaniko_execute
store_image_version