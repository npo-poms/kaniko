#!/bin/sh

echo "Defining function package_applications"
package_application() {
  app_dir=$1
  echo "Packaging '$app_dir' (pom version: $PROJECT_VERSION)"
  get_artifact_versions $app_dir $PROJECT_VERSION # defined in docker.yml
  ls -l $app_dir/target/*.war
  kaniko_execute $app_dir
}

package_applications() {
  for app_dir in $(echo $OS_APPLICATIONS | sed "s/,/ /g"); do
    package_application $app_dir
  done
  if [ -z "$OS_APPLICATIONS" ]; then
    echo "Packaging the root directory only"
    package_application .
  fi
  echo Finished packaging  $OS_APPLICATIONS
}