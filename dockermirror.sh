#!/bin/bash

set -e

source="${source}"
target="${REGISTRY}/${NAMESPACE}/${target}"

echo "Pulling image $source"

docker pull $source

echo "Tagging $source to $target"

docker tag $source $target

echo "Pushing $target"

docker push $target

echo "Cleaning"

docker system prune -a -f
