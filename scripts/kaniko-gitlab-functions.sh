##!/bin/sh
# This is the script can be used to build and push (via kaniko) an openshift statefull set.
# This script used to be present in gitlab templates, but that's unmaintainble and unreusable
# This can be used locally via run-in-docker.sh in a directory of interest


# as /kaniko.sh but add some functions related to running in gitlab

echo "kaniko gitlab functions"

AS_LATEST=${AS_LATEST:-'false'}

if [ -f job.env ] ; then
  echo "Found job.env"
  cat job.env
  . job.env
fi


# shellcheck source=${KANIKO_SCRIPTS}kaniko-functions.sh
if ! type os_app_name &> /dev/null ; then
. "$KANIKO_SCRIPTS"kaniko-functions.sh
fi

echo "Defining function setup_kaniko"
# Just arranges authentication by copying the config.json file to right spot
# $1 ~/.docker/config.json file. Defaults to DOCKER_AUTH_CONFIG
setup_kaniko() {
  mkdir -p /kaniko/.docker
  incoming="$1"
  if [ -z "$incoming" ] ; then
    echo "No incoming kaniko config file. Using $DOCKER_AUTH_CONFIG"
    incoming="$DOCKER_AUTH_CONFIG"
  fi
  if [ -e "$incoming" ] ; then
    echo "Copying $incoming to /kaniko/.docker/config.json"
    echo "lines:  $(wc -l $incoming)"
    cp $incoming /kaniko/.docker/config.json
  else
    echo "No incoming docker configuration file '$incoming'"
  fi
}



#  Stores relevant variables determined by get_artifact_versions in job.env
#  I'm not sure this is very useful. You can just as wel call get_articaft_versions again in the next job
#  which will have the same effect, but I think this is robust, because no need for fiddling with 'need=<previous job>',
#  which is confusing and error-prone.
store_image_version() {
  echo "IMAGE_TAG=$IMAGE_TAG" | tee job.env
  echo "IMAGE=$IMAGE" | tee -a job.env
  echo "IMAGE_NAME=$IMAGE_NAME" | tee -a job.env
  echo "FULL_IMAGE_NAME=$FULL_IMAGE_NAME" | tee -a job.env
  echo "PROJECT_VERSION=$PROJECT_VERSION" | tee -a job.env
}

echo "Define determine_image_version"
# If store_image_version was called earlier in the pipeline, the the results of this are in job.env
determine_image_version() {

  # used by plain docker builds
  if [ "$AS_LATEST" = 'true' ] ; then
    export LATEST="--destination $REGISTRY/$IMAGE_NAME"
  else
    export LATEST=
  fi

  if [ "$IMAGE_TAG" = '' ] ; then
      echo "No IMAGE_TAG defined. Breaking build. This must be defined in job rule!"
      exit 1
  fi
  if [ "$IMAGE_NAME" = '' ] ; then
     echo "No IMAGE_NAME defined. Taking from os_app_name"
     IMAGE_NAME=$(os_app_name)
     export IMAGE_NAME
  fi
  export IMAGE=$REGISTRY/$IMAGE_NAME:$IMAGE_TAG
  echo "IMAGE: $IMAGE"
}