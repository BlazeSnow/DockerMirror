#!/bin/bash

set -e

# 头部路径
HEAD="$HEAD"

# 镜像数量
count=$(jq '. | length' images.json)

# 默认平台
DEFAULT_PLATFORM="linux/amd64"

# 循环处理
for i in $(seq 0 $((count - 1))); do

	# 设定变量
	SOURCE="$(jq -r ".[$i].source" images.json)"
	TARGET="$HEAD/$(jq -r ".[$i].target" images.json)"
	PLATFORM="$(jq -r ".[$i].platform // empty" images.json)"
	if [[ -z "$PLATFORM" ]]; then
		PLATFORM="$DEFAULT_PLATFORM"
	fi

	# 使用crane获取digest
	SOURCE_digest=$(crane digest --platform="$PLATFORM" "$SOURCE" 2>/dev/null || true)
	TARGET_digest=$(crane digest --platform="$PLATFORM" "$TARGET" 2>/dev/null || true)

	# 分隔符
	echo "----------------------------------------"
	echo "源镜像: $SOURCE"
	echo "digest: $SOURCE_digest"

	echo "目的地: $TARGET"
	echo "digest: $TARGET_digest"

	# 相同则跳过拉取和推送
	if [[ -n "$SOURCE_digest" && -n "$TARGET_digest" && "$SOURCE_digest" == "$TARGET_digest" ]]; then
		echo "✅ 源和目的地内容一致，跳过拉取和推送"
		continue
	fi

	# 拉取镜像
	echo "⬇️ 拉取镜像"
	docker pull --quiet --platform="$PLATFORM" "$SOURCE"

	# 重命名镜像
	echo "🔄 重命名镜像"
	docker tag "$SOURCE" "$TARGET" >/dev/null

	# 推送镜像
	echo "⬆️ 推送镜像"
	docker push --quiet "$TARGET"

	# 清理镜像
	echo "🧹 清理镜像"
	docker rmi "$SOURCE" "$TARGET" &>/dev/null || true

done
