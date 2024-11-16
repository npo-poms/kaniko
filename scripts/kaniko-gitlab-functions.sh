#!/bin/sh
# This is the script can be used to build and push (via kaniko) an openshift statefull set.
# This script used to be present in gitlab templates, but that's unmaintainble and unreusable
# This can be used locally via run-in-docker.sh in a directory of interest


# as /kaniko.sh but add some functions related to running in gitlab

echo "kaniko gitlab functions"

AS_LATEST=${AS_LATEST:-'false'}

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



#  Stores relevant variables determined by get_artifact_versions in job.env
#  I'm not sure this is very useful. You can just as wel call get_articaft_versions again in the next job
#  which will have the same effect, but I think this is robust, because no need for fiddling with 'need=<previous job>',
#  which is confusing and error-prone.
store_image_version() {
  echo "Storing variables in job.env"
  echo "IMAGE_TAG=$IMAGE_TAG" | tee job.env
  echo "PROJECT_VERSION=$PROJECT_VERSION" | tee -a job.env
  echo "OS_APPLICATIONS=$OS_APPLICATIONS" | tee -a job.env
  #echo AS_LATEST=${AS_LATEST:-'false'}

}

