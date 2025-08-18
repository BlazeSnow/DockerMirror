# /bin/bash

set -e

set SOURCE=${{ matrix.image.source }}
SET TARGET=${{ matrix.image.target }}
SET REGISTRY=${{ env.REGISTRY }}
SET NAMESPACE=${{ env.NAMESPACE }}

docker pull ${SOURCE}

docker tag ${SOURCE} ${REGISTRY}${NAMESPACE}${TARGET}

docker push ${REGISTRY}${NAMESPACE}${TARGET}

docker system prune -a -f