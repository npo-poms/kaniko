#!/bin/sh
echo "--------"

export DOCKER_DIR
DOCKER_DIR="$(pwd)"
echo "Executing in ${DOCKER_DIR}"
export DOCKER_BUILD_ARGS=  # Uses eval, when overriding escape whitespace: '--build-arg\ "FOO=BAR"'
export REGISTRY="${REGISTRY:-registry.npohosting.nl}"
export DOCKER_AUTH_CONFIG_FILE=$HOME/.docker/config-gitlab.json
export KANIKO_ARGS='--cache=true --cache-copy-layers=true'
export AS_LATEST='false'
export TRACE='false'

echo Using registry ${REGISTRY}

. "$KANIKO_SCRIPTS"kaniko-gitlab-functions.sh

. "$KANIKO_SCRIPTS"kaniko-maven.sh

package_wars

