##!/bin/sh
if ! type os_app_name &> /dev/null; then
  . "$KANIKO_SCRIPTS"dockerfile-functions.sh
fi

# sets up kaniko, executes it, and stores some variables
# param: directory to execute for
run_kaniko() {
  echo "Using build args $DOCKER_BUILD_ARGS"
  setup_kaniko "$DOCKER_AUTH_CONFIG_FILE"
  kaniko_execute "$@"
  store_image_version
}


echo "Defining function kaniko_execute"
# $1: is the directory to run for, defaults to DOCKER_DIR
# $2: is a version  to build defaults to PROJECT_VERSION
kaniko_execute() {
  dir="$1"
  if [ -z "$dir" ] ; then
    dir=$DOCKER_DIR
    echo "No directory specified, taking from environment DOCKER_DIR=$DOCKER_DIR"
  fi
  version="$2"
  if [ -z "$version" ] ; then
     echo "Version no specified, taking from environment PROJECT_VERSION=$PROJECT_VERSION"
     version=$PROJECT_VERSION
  fi

  if [ -z "$IMAGE" ] ; then
      echo "Missing IMAGE variable. Trying to find now by calling get_actifact_versions"
      get_artifact_versions $dir $version
  fi
  image="$IMAGE"
  if [ -z "$image" ] ; then
      echo "No image found "
      exit 1;
  fi

  if [ -z "$version" ] ; then
     echo "Building and pushing image: \"$image\" ($LATEST) (version not found)"
  else
     echo "Building and pushing image: \"$image\" ($LATEST), (project) version: $version"
  fi
  if [ ! -f "/kaniko/executor" ] ; then
    echo "kaniko/executor not found"
    return 1
  fi
  echo Cache $REGISTRY/$NAMESPACE/caches
  /kaniko/executor $KANIKO_ARGS \
    --context $dir \
    --dockerfile $dir/Dockerfile \
    --build-arg PROJECT_VERSION=$version \
    --build-arg CI_COMMIT_REF_NAME=$CI_COMMIT_REF_NAME \
    --build-arg CI_COMMIT_SHA=$CI_COMMIT_SHA \
    --build-arg CI_COMMIT_TIMESTAMP=$CI_COMMIT_TIMESTAMP \
    --build-arg CI_COMMIT_TITLE="$CI_COMMIT_TITLE" \
    --custom-platform=linux/amd64 \
    $DOCKER_BUILD_ARGS \
    $LATEST \
    --cache-repo $REGISTRY/$NAMESPACE/caches \
    --destination $image\
    --cleanup
}
