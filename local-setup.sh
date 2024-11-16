# Sets up some environment as gitlab  would do.

REGISTRY=${REGISTRY:-registry.npohosting.nl}
NAMESPACE=${NAMESPACE:-poms}

CI_COMMIT_REF_NAME="$(git symbolic-ref -q --short HEAD || git describe --tags --exact-match)"
PROJECT_VERSION=$(mvn help:evaluate -Dexpression=project.version -q -DforceStdout)
echo "Found project version ${PROJECT_VERSION}"


if [  "$IMAGE_TAG" = "" ] ; then  # you can specify the image-tag by:  IMAGE_TAG=.. kaniko.sh
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
fi

echo "image tag $IMAGE_TAG"
