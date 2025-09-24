#!/bin/bash

set -e

# 镜像数量
count=$(jq '. | length' images.json)

# 循环处理
for i in $(seq 0 $((count - 1))); do

	# 设定变量
	SOURCE="$(jq -r ".[$i].source" images.json)"
	TARGET="$HEAD/$(jq -r ".[$i].target" images.json)"

	# 分隔符
	echo ""
	echo "----------------------------------------"
	echo "源镜像：$SOURCE"
	echo "目的地：$TARGET"
	echo "----------------------------------------"
	echo ""

	# 拉取镜像
	echo "⬇️ 拉取镜像"
	docker pull --quiet "$SOURCE"

	# 重命名镜像
	echo "🔄 重命名镜像"
	docker tag "$SOURCE" "$TARGET" >/dev/null

	# 推送镜像
	echo "⬆️ 推送镜像"
	docker push --quiet "$TARGET"

	# 清理镜像
	echo "🧹 清理镜像"
	docker system prune -a -f >/dev/null

done
