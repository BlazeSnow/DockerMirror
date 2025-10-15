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

	# 相同则跳过
	if [[ -n "$SOURCE_digest" && -n "$TARGET_digest" && "$SOURCE_digest" == "$TARGET_digest" ]]; then
		echo "✅ 源和目的地内容一致，跳过同步"
		continue
	fi

	# 同步镜像
	echo "🔄 同步镜像"
	crane copy --platform="$PLATFORM" "$SOURCE" "$TARGET"
	echo "✅ 同步完成"

	# 清理镜像
	echo "🧹 清理镜像"
	docker rmi "$SOURCE" "$TARGET" &>/dev/null || true

done
