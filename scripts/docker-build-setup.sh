#!/bin/sh
echo "docker build setup"

if [ "$TRACE" = "true" ] ; then
   echo "Tracing"
   set -xv
   env
fi


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



echo "defining os_app_name"
# Take name of application from Dockerfile
# This will be the name of the resulting docker image (without namespace). E.g. 'vproapi'.
os_app_name() {
  DIR=$1
  appname=$(awk -F= '$1 == "ARG NAME"{ print $2}' $DIR/Dockerfile)
  if [ -z "$appname" ] ; then
     >&2 echo "Could not determine application name from Dockerfile (ARG NAME=). Getting from IMAGE_NAME=$IMAGE_NAME"
     appname=$IMAGE_NAME
  fi
  if [ -z "$appname" ] ; then
    postfix=${DIR//[.\/]/} # remove dots and slashes
    if [ -z "$postfix" ] ; then
       appname=$CI_PROJECT_NAME
    else
       appname=$CI_PROJECT_NAME-$postfix
    fi
    >&2 echo "Could not determine application name from Dockerfile or IMAGE_NAME. Using $appname"
  fi
  echo $appname
}

echo "defining get_artifact_versions"

# exports PROJECT_VERSION, IMAGE_TAG, IMAGE, IMAGE_NAME
# first argument: directory containing the docker file
# second argument: version (exported as PROJECT_VERSION)
# the name of the image is determined with os_app_name
get_artifact_versions() {
  DIR=$1
  export PROJECT_VERSION=$2
  # gets name from docker file
  OS_APPLICATION=$(os_app_name $DIR)
  exit_code=$?
  if [ $exit_code != '0' ] ; then
      echo "Error with os_app_name function $exit_code"
      exit $exit_code
  fi
  if [ -z "$IMAGE_TAG" ] ; then
    echo "No IMAGE_TAG defined. Should have been in rules"
    exit 1
  fi
  if [ -z "$NAMESPACE" ] ; then
    echo "No docker NAMESPACE defined"
    exit 1
  fi
  export IMAGE_NAME=$OS_APPLICATION
  export FULL_IMAGE_NAME=$NAMESPACE/$IMAGE_NAME:$IMAGE_TAG
  export IMAGE=$REGISTRY/$FULL_IMAGE_NAME

  echo "Using image artifact: \"$IMAGE\" (tag: \"$IMAGE_TAG\", full: \"$FULL_IMAGE_NAME\")"
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

