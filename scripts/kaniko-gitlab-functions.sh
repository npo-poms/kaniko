#!/bin/sh
# This is the script can be used to build and push (via kaniko) an openshift statefull set.
# This script used to be present in gitlab templates, but that's unmaintainble and unreusable
# This can be used locally via run-in-docker.sh in a directory of interest


# as /kaniko.sh but add some functions related to running in gitlab

echo "kaniko gitlab functions"


if [ -f job.env ] ; then
  echo "Found job.env!"
  cat job.env
  . ./job.env
else
  echo "No job.env in $(pwd)"
fi

# shellcheck source=${KANIKO_SCRIPTS}kaniko-functions.sh
if ! type os_app_name &> /dev/null ; then
. "$KANIKO_SCRIPTS"kaniko-functions.sh
fi




