#!/bin/sh
echo "--------"

export DOCKER_DIR
DOCKER_DIR="$(pwd)"
echo "Executing in ${DOCKER_DIR}"

TRACE=${TRACE:-'false'}

if [ "$TRACE" = 'true' ]; then
  set -x
fi


if [ -f job.env ] ; then
  echo "Found job.env!"
  cat job.env
  . ./job.env
else
  echo "No job.env in $(pwd)"
fi


. "$KANIKO_SCRIPTS"kaniko-functions.sh


fun=$1
if [ "$fun" = "help" ] ;then
  echo usage
  echo $0      Default 'run_kaniko_all' to deploy all found docker deployables
  echo         or if OS_APPLICATIONS is defined in all the subdirectories it
  exit
fi
if [ -z "$fun" ] ; then
  fun="run_kaniko_all"
fi
$fun .
