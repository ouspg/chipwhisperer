#!/bin/bash
# Credits to https://rs-stuff.dev/2023/01/29/podman-multiarch/
# Original license: https://rs-stuff.dev/LICENSE.md
# Modified by: Niklas Saari

if [[ -z "${VERSION_TAG:+x}" ]]; then
    echo "Please set up VERSION_TAG variable"
    exit 2
fi

if [[ -z "${REGISTRY:+x}" ]]; then
  echo "Please set up REGISTRY variable"
  exit 2
fi

if [[ -z "${USER:+x}" ]]; then
  echo "Please set up USER variable"
  exit 2
fi

# Publish flag
if [[ "$#" -eq 1 ]] && [[ "$1" == "-p" ]]; then
  SHOULD_PUBLISH=1
fi
# Manifest name
MANIFEST_NAME="image-multiarch"
# Build specific variables
SCRIPT_PATH="$(dirname -- $(readlink -f -- "$0"))"
echo "Script path: $SCRIPT_PATH"
# BUILD_PATH="$(dirname -- ${SCRIPT_PATH})"
BUILD_PATH="${SCRIPT_PATH}"
REGISTRY="$REGISTRY"
USER="$USER"
IMAGE_NAME="chipwhisperer"
IMAGE_TAG="${VERSION_TAG}"

# Base image name
BASE_IMAGE_NAME="${REGISTRY}/${USER}/${IMAGE_NAME}:${IMAGE_TAG}"
echo "Base image name: $BASE_IMAGE_NAME"
echo "Build path: $BUILD_PATH"
# Create a multi-architecture manifest
podman manifest create ${MANIFEST_NAME}

for arch in amd64 arm64; do
    echo "Building $BASE_IMAGE_NAME-$arch"
    podman buildx build \
      -t "$BASE_IMAGE_NAME-$arch" \
      --build-arg="NOTEBOOK_PASS=jupyter" \
      --squash-all \
      --manifest "${MANIFEST_NAME}" \
      --platform linux/"${arch}" \
      "${BUILD_PATH}" 
done
# Publish images to the registry
if [[ "$SHOULD_PUBLISH" -eq 1 ]]; then
  podman push --all "${MANIFEST_NAME}" \
  "docker://$BASE_IMAGE_NAME"
fi

