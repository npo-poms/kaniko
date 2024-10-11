#!/bin/bash
# This script calls kaniko (in docker) for the current directory. You can put it in your path
# It's actually calling the scripts/script.sh in ghcr.io/npo-poms/kaniko

KANIKO_IMAGE=npo-poms/kaniko
#KANIKO_IMAGE=ghcr.io/npo-poms/kaniko:2
PROJECT_VERSION=$(mvn help:evaluate -Dexpression=project.version -q -DforceStdout)
docker run -v ~:/root -v "$(pwd)":/workspace \
    -e PROJECT_VERSION=$PROJECT_VERSION \
    -e IMAGE_TAG=dev \
    -e NAMESPACE=poms \
    -e CI_COMMIT_REF_NAME="$(git symbolic-ref -q --short HEAD || git describe --tags --exact-match)" \
    -e CI_COMMIT_SHA="$(git show --format="%H"  --no-patch)" \
    -e CI_COMMIT_TIMESTAMP="$(git show --format="%aI"  --no-patch)" \
    -e CI_COMMIT_TITLE="$(git show --format="%s"  --no-patch)" \
   $KANIKO_IMAGE

