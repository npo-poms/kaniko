#!/bin/sh
echo "kaniko build setup";
if [ "$TRACE" == "true" ] ; then
  echo "Tracing"
  set -xv
  env
fi

echo "Defining function setup_kaniko"
# Just arranges authentication by copying the config.json file to right spot
function setup_kaniko() {
  mkdir -p /kaniko/.docker
  incoming="$1"
  if [[ -z "$incoming" ]] ; then
    echo "No incoming kaniko config file. Using $DOCKER_AUTH_CONFIG"
    incoming="$DOCKER_AUTH_CONFIG"
  fi
  echo "Copying $incoming to /kaniko/.docker/config.json"
  echo "lines: " $(wc -l $incoming)
  cp $incoming /kaniko/.docker/config.json
}

echo "Defining function kaniko_execute"
function kaniko_execute() {
  dir="$1"
  if [[ -z "$dir" ]] ; then
    dir=$DOCKER_DIR
  fi
  version="$2"
  if [[ -z "$version" ]] ; then
     echo "Version no specified, taking $PROJECT_VERSION"
     version=$PROJECT_VERSION
  fi

  if [[ -z "$IMAGE" ]] ; then
      echo "Missing IMAGE variable. Trying to find now by calling get_actifact_versions"
      get_artifact_versions $dir $version
  fi
  image="$IMAGE"
  if [[ -z "$image" ]] ; then
      echo "No image found "
      exit 1;
  fi


  if [[ -z "$version" ]] ; then
     echo "Building and pushing image: \"$image\" ($LATEST) (version not found)"
  else
     echo "Building and pushing image: \"$image\" ($LATEST), (project) version: $version"
  fi
  set -x
  /kaniko/executor $KANIKO_ARGS \
    --context $dir \
    --dockerfile $dir/Dockerfile \
    --build-arg PROJECT_VERSION=$version \
    --build-arg CI_COMMIT_REF_NAME=$CI_COMMIT_REF_NAME \
    --build-arg CI_COMMIT_SHA=$CI_COMMIT_SHA \
    --build-arg CI_COMMIT_TIMESTAMP=$CI_COMMIT_TIMESTAMP \
    --build-arg CI_COMMIT_TITLE="$CI_COMMIT_TITLE" \
    $DOCKER_BUILD_ARGS \
    $LATEST \
    --destination $image\
    --cleanup
}
