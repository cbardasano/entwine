#!/bin/bash

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$DIR/../.." && pwd)"

CONTAINER_NAME="cbardai/entwine"
VERSION="3.2.2"

WIPE_CACHE="$1"
if [ -z "$WIPE_CACHE" ]; then
    echo "Not wiping cache";
else
    WIPE_CACHE="--no-cache"
    echo "Wiping cache '$WIPE_CACHE'";

fi

docker buildx build \
    -t "$CONTAINER_NAME:$VERSION-amd64" "$REPO_ROOT" \
    --platform linux/amd64  \
    -f "$DIR/Dockerfile" --load $WIPE_CACHE

docker buildx build -t "$CONTAINER_NAME:$VERSION-arm64" "$REPO_ROOT" \
    -f "$DIR/Dockerfile" --platform linux/arm64 \
     --load $WIPE_CACHE


docker push $CONTAINER_NAME:$VERSION-arm64
docker push $CONTAINER_NAME:$VERSION-amd64

docker manifest create "$CONTAINER_NAME:$VERSION" \
    --amend "$CONTAINER_NAME:$VERSION-arm64" \
    --amend "$CONTAINER_NAME:$VERSION-amd64"

docker manifest inspect $CONTAINER_NAME:$VERSION

docker manifest push "$CONTAINER_NAME:$VERSION"
