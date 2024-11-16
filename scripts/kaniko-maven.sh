##!/bin/sh
# package found war file (or files using OS_APPLICATIONS)

if ! type kaniko_execute &> /dev/null ; then
  . "$KANIKO_SCRIPTS"kaniko-functions.sh
fi

echo "Defining function package_war(s)"

package_war() {
  app_dir=$1
  echo -e "----------\nPackaging ${EMP}'$app_dir'${NC} (pom version: $PROJECT_VERSION)"
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
  elif [ ! -f Dockerfile ]; then
    echo "Packaging the root directory only"
    package_war .
  else
    echo "NOTHING to do. No Dockerfile and not OS_APPLICATIONS find"
  fi

}

package_applications() {
  package_wars "$@"
}