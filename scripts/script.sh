#!/bin/sh
echo "--------"

export DOCKER_DIR
DOCKER_DIR="$(pwd)"
echo "Executing in ${DOCKER_DIR}"

TRACE=${TRACE:-'false'}

if [ "$TRACE" = 'true' ]; then
  set -x
fi

. "$KANIKO_SCRIPTS"kaniko-gitlab-functions.sh

. "$KANIKO_SCRIPTS"kaniko-maven.sh

fun=$1
if [ "$fun" = "help" ] ;then
  echo usage
  echo $0      Run 'run_kaniko_maven' to deploy the war project of the current directory
  echo         or if OS_APPLICATIONS is defined in all the subdirectories it
  exit
fi
if [ -z "$fun" ] ; then
  fun="run_kaniko_maven"
fi
$fun .
