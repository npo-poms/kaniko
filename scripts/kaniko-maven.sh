##!/bin/sh
# package found war file (or files using OS_APPLICATIONS)

if ! type kaniko_execute &> /dev/null ; then
  . "$KANIKO_SCRIPTS"kaniko-functions.sh
fi

echo "Defining function package_war(s)"

package_war() {
  app_dir=$1
  echo -e "----------\nPackaging ${TXT_HI}'$app_dir'${TXT_CLEAR} (pom version: $PROJECT_VERSION)"
  get_artifact_versions $app_dir $PROJECT_VERSION # defined in docker.yml
  ls -l $app_dir/target/*.war
  kaniko_execute $app_dir
}
package_application() {
  package_war "$@"
}

package_wars() {
  if [ ! -z  "$OS_APPLICATIONS" ] ; then
    for app_dir in $(echo $OS_APPLICATIONS | sed "s/,/ /g"); do
      package_war $app_dir
    done
    echo Finished packaging  $OS_APPLICATIONS
  elif [ -f Dockerfile ]; then
    echo "Packaging the root directory only"
    package_war .
  else

    echo "No Dockerfile and no OS_APPLICATIONS variable found"
    OS_APPLICATIONS=$(find . -name '*.war' -exec sh -c 'f=$(dirname $1); (cd $f/..;  basename $PWD) ;' shell {} \; | tr '\n' ','  | sed 's/,$//')
    if [ ! -z "$OS_APPLICATIONS" ] ; then
      echo "Guessed OS_APPLICATIONS=$OS_APPLICATIONS"
      package_wars
    else
      echo "Could not guess either"
    fi
  fi

}

package_applications() {
  package_wars "$@"
}

run_kaniko_maven() {
  echo "Using build args $DOCKER_BUILD_ARGS"
  setup_kaniko "$DOCKER_AUTH_CONFIG_FILE"
  package_wars
  store_image_version
}