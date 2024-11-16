##!/bin/sh
KANIKO_ARGS=${KANIKO_ARGS:-'--cache=true --cache-copy-layers=true'}

DOCKER_BUILD_ARGS=${DOCKER_BUILD_ARGS:-}  # Uses eval, when overriding escape whitespace: '--build-arg\ "FOO=BAR"'
AS_LATEST=${AS_LATEST:-'false'}


if ! type os_app_name &> /dev/null; then
  . "$KANIKO_SCRIPTS"dockerfile-functions.sh
fi

# sets up kaniko, executes it in a dir, and stores some variables
# $1: directory to execute for
run_kaniko() {
  echo "Using build args $DOCKER_BUILD_ARGS"
  setup_kaniko
  kaniko_execute $1
  store_variables
  store_image_name
}

#  Stores relevant variables determined by get_artifact_versions in job.env
#  I'm not sure this is very useful. You can just as wel call get_articaft_versions again in the next job
#  which will have the same effect, but I think this is robust, because no need for fiddling with 'need=<previous job>',
#  which is confusing and error-prone.
store_variables() {
  echo "Storing variables in job.env"
  echo "IMAGE_TAG=$IMAGE_TAG" | tee job.env
  echo "PROJECT_VERSION=$PROJECT_VERSION" | tee -a job.env
  echo "OS_APPLICATIONS=$OS_APPLICATIONS" | tee -a job.env
  #echo AS_LATEST=${AS_LATEST:-'false'}
}

store_image_name() {
  echo IMAGE=$IMAGE | tee -a job.env
}

echo "Defining function setup_kaniko"
# Just arranges authentication by copying the config.json file to right spot
setup_kaniko() {
  mkdir -p /kaniko/.docker
  incoming="$DOCKER_AUTH_CONFIG"
  if [ -e "$incoming" ] ; then
    echo "Copying $incoming to /kaniko/.docker/config.json"
    echo "lines:  $(wc -l $incoming)"
    cp $incoming /kaniko/.docker/config.json
  else
    echo "No incoming docker configuration file '$incoming'"
  fi
}



echo "Defining function kaniko_execute"
# Determins the IMAGE and runs kaniko
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
   # used by plain docker builds
  if [ "$AS_LATEST" = 'true' ] ; then
    export LATEST="--destination $REGISTRY/$FULL_IMAGE_NAME"
  else
    export LATEST=
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

