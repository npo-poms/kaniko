#!/bin/sh

JOB_ENV=${JOB_ENV:-'job.env'}

echo "--------"

export DOCKER_DIR
DOCKER_DIR="$(pwd)"
echo "Executing in ${DOCKER_DIR}"

TRACE=${TRACE:-'false'}

if [ "$TRACE" = 'true' ]; then
  set -x
fi


if [ -f ${JOB_ENV} ] ; then
  echo "Found ${JOB_ENV}!"
  cat ${JOB_ENV}
  . ./"${JOB_ENV}"
else
  echo "No ${JOB_ENV} in $(pwd)"
fi


. "$KANIKO_SCRIPTS"kaniko-functions.sh


fun=$1
if [ "$fun" = "help" ] ;then
  echo usage
  echo "$0      Default 'run_kaniko_all' to deploy all found docker deployables"
  echo  "       or if OS_APPLICATIONS is defined in all the subdirectories it"
  exit 1
fi
if [ -z "$fun" ] ; then
  fun="run_kaniko_all"
fi
echo "Calling $fun"
$fun .
