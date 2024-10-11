#!/bin/bash
IMAGE=npo-poms/kaniko
PROJECT_VERSION=$(mvn help:evaluate -Dexpression=project.version -q -DforceStdout)
docker run -v ~:/root -v $(pwd):/workspace \
    -e PROJECT_VERSION=$PROJECT_VERSION \
    -e IMAGE_TAG=dev \
    -e NAMESPACE=poms \
    $IMAGE