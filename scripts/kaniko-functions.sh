##!/bin/sh

REGISTRY="${REGISTRY:-registry.npohosting.nl}"
NAMESPACE=${NAMESPACE:-poms}
KANIKO_CACHE=${KANIKO_CACHE:-"$REGISTRY/$NAMESPACE/caches"}

# kaniko only has remote caches, which does not make much sense in our cases
KANIKO_ARGS=${KANIKO_ARGS:-'--cache=false --cache-copy-layers=false'}

DOCKER_BUILD_ARGS=${DOCKER_BUILD_ARGS:-}  # Uses eval, when overriding escape whitespace: '--build-arg\ "FOO=BAR"'
AS_LATEST=${AS_LATEST:-'false'}

JOB_ENV=${JOB_ENV:-'job.env'}



if ! type os_app_name &> /dev/null; then
  . "$KANIKO_SCRIPTS"dockerfile-functions.sh
fi

# For a certain directory, calculate the docker image name, and run kaniko
# $1: the directory to run for
package_docker() {
  app_dir=$1
  echo -e "----------\nPackaging ${TXT_HI}'$app_dir'${TXT_CLEAR} (pom version: $PROJECT_VERSION)"
  get_docker_image_name $app_dir $PROJECT_VERSION # defined in docker.yml
  kaniko_execute $app_dir
}


package_all_docker() {
  amount=0
  if [ ! -z  "$OS_APPLICATIONS" ] ; then
    for app_dir in ${OS_APPLICATIONS//,/ }; do
      package_docker $app_dir
      amount=$((amount+1))
    done
    echo Finished packaging  $OS_APPLICATIONS
  elif [ -f Dockerfile ]; then
    echo "Packaging the root directory only"
    package_docker .
    amount=$((amount+1))
  else
    echo "No Dockerfile and no OS_APPLICATIONS variable found"
    # We assume that we have to build all Dockerfiles in subdirectories, that have 'ARG NAME'
    OS_APPLICATIONS=$(find . -maxdepth 2  -mindepth 2 -name "Dockerfile" -exec sh -c 'f=$(dirname $(grep -l -i -E "ARG\s+NAME"  $1)); basename $f;'   shell {} \;  | tr '\n' ','  | sed 's/,$//')
    if [ ! -z "$OS_APPLICATIONS" ] ; then
      echo "Guessed OS_APPLICATIONS=$OS_APPLICATIONS"
      package_all_docker
      amount=$?
    else
      echo "Could not guess either for ${PROJECT_VERSION}"
    fi
  fi
  echo "Built $amount images"
  return $amount
}

# sets up kaniko, executes it in a dir, and stores some variables
# $1: directory to execute for
run_kaniko() {
  echo "Using build args $DOCKER_BUILD_ARGS"
  setup_kaniko
  package_docker $1
  store_variables
  store_image_name
}

run_kaniko_all() {
  echo "Using build args $DOCKER_BUILD_ARGS"
  setup_kaniko "$DOCKER_AUTH_CONFIG_FILE"
  package_all_docker
  amount=$?
  store_variables
  if [ $amount == 1 ] ; then
    store_image_name
  fi
}

#  Stores relevant variables determined by get_docker_image_name in job.env
#  I'm not sure this is very useful. You can just as wel call get_articaft_versions again in the next job
#  which will have the same effect, but I think this is robust, because no need for fiddling with 'need=<previous job>',
#  which is confusing and error-prone.
store_variables() {
  echo "Storing variables in ${JOB_ENV}"
  echo "IMAGE_TAG=$IMAGE_TAG" | tee ${JOB_ENV}
  echo "PROJECT_VERSION=$PROJECT_VERSION" | tee -a ${JOB_ENV}
  echo "OS_APPLICATIONS=$OS_APPLICATIONS" | tee -a ${JOB_ENV}
  #echo AS_LATEST=${AS_LATEST:-'false'}
}

store_image_name() {
  echo "Storing image name in ${JOB_ENV}"
  echo IMAGE=$IMAGE | tee -a ${JOB_ENV}
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
      get_docker_image_name $dir $version
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



  CACHE_ARG=$([ "$KANIKO_CACHE" == "" ] || [ "$KANIKO_CACHE" == "false" ] && echo "" || echo "--cache-repo $KANIKO_CACHE")
  echo Cache $CACHE_ARG, KANIKO_ARGS: $KANIKO_ARGS


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
    $CACHE_ARG \
    --destination $image\
    --cleanup 2>&1 | ts '[%Y-%m-%d %H:%M:%S]'
  kaniko_result=$?
  echo "Kaniko result: $kaniko_result" |  ts '[%Y-%m-%d %H:%M:%S]'
  if [ $kaniko_result -ne 0 ] ; then
    echo "Kaniko failed"
    exit $kaniko_result
  fi
}

