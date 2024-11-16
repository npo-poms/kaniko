#!/bin/sh
# Sets up some environment as gitlab  would do.
# called by kaniko.sh and by local-setup.sh, produces job.env

echo CI_COMMIT_REF_NAME="$(git symbolic-ref -q --short HEAD || git describe --tags --exact-match)" > job.env
echo PROJECT_VERSION=$(mvn help:evaluate -Dexpression=project.version -q -DforceStdout) >> job.env
. job.env

if [  "$IMAGE_TAG" = "" ] ; then  # you can specify the image-tag by:  IMAGE_TAG=.. kaniko.sh
  case $CI_COMMIT_REF_NAME in
    "main")
       IMAGE_TAG=dev
       ;;
     *SNAPSHOT*)
      IMAGE_TAG=$(echo "${PROJECT_VERSION}-dev" | tr '[:upper:]' '[:lower:]')
      ;;
    *)
      IMAGE_TAG=$(echo "${PROJECT_VERSION}" | tr '[:upper:]' '[:lower:]')
      ;;
  esac
fi

echo IMAGE_TAG=$IMAGE_TAG >> job.env

