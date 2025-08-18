#!/bin/bash

set -e

SOURCE="${SOURCE}"
TARGET="${TARGET}"

echo "Pulling image $SOURCE"

docker pull $SOURCE

echo "Tagging $SOURCE to $TARGET"

docker tag $SOURCE $TARGET

echo "Pushing $TARGET"

docker push $TARGET

echo "Cleaning"

docker system prune -a -f
