#!/bin/bash
# This script calls kaniko (in docker) for the current directory. You can put it in your path
# It's actually calling the scripts/script.sh in ghcr.io/npo-poms/kaniko

REGISTRY=${REGISTRY:-registry.npohosting.nl}
NAMESPACE=${NAMESPACE:-poms}

# REGISTRY: openshift-image-registry.apps.cluster.chp4.io.

#echo "Registry: ${REGISTRY}"
KANIKO_IMAGE=npo-poms/kaniko
#KANIKO_IMAGE=ghcr.io/npo-poms/kaniko:3

PROJECT_VERSION=$(mvn help:evaluate -Dexpression=project.version -q -DforceStdout)
echo "Found project version ${PROJECT_VERSION}"

CI_COMMIT_REF_NAME="$(git symbolic-ref -q --short HEAD || git describe --tags --exact-match)"

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

echo "image tag $IMAGE_TAG"


docker run -v ~/conf:/root/conf -v ~/.docker:/root/.docker -v "$(pwd)":/workspace \
    -e PROJECT_VERSION="$PROJECT_VERSION" \
    -e IMAGE_TAG=${IMAGE_TAG} \
    -e NAMESPACE=${NAMESPACE} \
    -e REGISTRY="${REGISTRY}" \
    -e CI_COMMIT_REF_NAME="${CI_COMMIT_REF_NAME}" \
    -e CI_COMMIT_SHA="$(git show --format="%H"  --no-patch)" \
    -e CI_COMMIT_TIMESTAMP="$(git show --format="%aI"  --no-patch)" \
    -e CI_COMMIT_TITLE="$(git show --format="%s"  --no-patch)" \
   $KANIKO_IMAGE

