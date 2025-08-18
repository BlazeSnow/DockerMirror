#!/bin/bash

set -e

# 镜像数量
count=$(jq '. | length' images.json)

# 循环处理
for i in $(seq 0 $((count - 1))); do

    # 设定变量
    SOURCE="docker.io/$(jq -r ".[$i].source" images.json)"
    TARGET="$REGISTRY/$NAMESPACE/$(jq -r ".[$i].target" images.json)"

    # 拉取镜像
    echo "⬇️ 拉取镜像"
    docker pull "$SOURCE"

    # 重命名镜像
    echo "🔄 重命名镜像"
    docker tag "$SOURCE" "$TARGET"

    # 推送镜像
    echo "⬆️ 推送镜像"
    docker push "$TARGET"

    # 清理镜像
    echo "🧹 清理镜像"
    docker system prune -a -f

done
