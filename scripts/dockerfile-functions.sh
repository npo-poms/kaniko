##!/bin/sh
echo "docker build setup"

TXT_HI="\e[93m" && TXT_CLEAR="\e[0m"

# scripts around the 'os_app_name' function, that determin the artifact name using information from Dockerfil



echo "defining os_app_name"
# Take name of application from Dockerfile
# This will be the name of the resulting docker image (without namespace). E.g. 'vproapi'.
os_app_name() {
  DIR=$1
  if [ ! -f $DIR/Dockerfile ] ; then
    echo -e "${TXT_HI}NO Dockerfile found in $(pwd)${TXT_CLEAR}"
    ls $DIR
  fi
  appname=$(awk -F= '$1 == "ARG NAME"{ print $2}' $DIR/Dockerfile)
  if [ -z "$appname" ] ; then
     >&2 echo "Could not determine application name from $DIR/Dockerfile (ARG NAME=). Getting from IMAGE_NAME=$IMAGE_NAME"

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
      return $exit_code
  fi
  if [ -z "$IMAGE_TAG" ] ; then
    echo "No IMAGE_TAG defined. Should have been in rules"
    return 1
  fi
  if [ -z "$NAMESPACE" ] ; then
    echo "No docker NAMESPACE defined"
    return 1
  fi
  export IMAGE_NAME=$OS_APPLICATION
  export FULL_IMAGE_NAME=$NAMESPACE/$IMAGE_NAME:$IMAGE_TAG
  export IMAGE=$REGISTRY/$FULL_IMAGE_NAME

  echo "Using image artifact: \"$IMAGE\" (tag: \"$IMAGE_TAG\", full: \"$FULL_IMAGE_NAME\")"
}


