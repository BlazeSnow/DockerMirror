# /bin/bash

set -e

echo "Pulling image $source"

docker pull $source

echo "Tagging $source to $REGISTRY$NAMESPACE$target"

docker tag $source $REGISTRY$NAMESPACE$target

echo "Pushing $REGISTRY$NAMESPACE$target"

docker push $REGISTRY$NAMESPACE$target

echo "Cleaning"

docker system prune -a -f
