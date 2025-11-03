#!/bin/sh

set -e

# 检查images.json文件
if [ ! -f images.json ]; then
	echo "❌ 错误：images.json不存在"
	exit 1
fi

# 检查images.json文件中的target有无重复
duplicate_targets=$(jq -r '.[].target' images.json | sort | uniq -d)
if [ -n "$duplicate_targets" ]; then
	echo "❌ 错误：target存在重复"
	echo "$duplicate_targets"
	exit 1
fi

# 检查默认平台设置
if [ -z "$DEFAULT_PLATFORM" ]; then
	echo "⚠️ 警告：DEFAULT_PLATFORM未设置，默认：linux/amd64"
	export DEFAULT_PLATFORM="linux/amd64"
fi

# 镜像数量
count=$(jq '. | length' images.json)

# 循环处理
for i in $(seq 0 $((count - 1))); do

	# 设定变量
	SOURCE="$(jq -r ".[$i].source" images.json)"
	TARGET="$(jq -r ".[$i].target" images.json)"
	PLATFORM="$(jq -r ".[$i].platform // empty" images.json)"
	if [ -z "$PLATFORM" ]; then
		PLATFORM="$DEFAULT_PLATFORM"
	fi

	# 使用crane获取digest
	SOURCE_digest=$(crane digest --platform="$PLATFORM" "$SOURCE" 2>/dev/null || true)
	TARGET_digest=$(crane digest --platform="$PLATFORM" "$TARGET" 2>/dev/null || true)

	# 分隔符
	echo "----------------------------------------"
	echo "$(date '+%Y-%m-%d %H:%M:%S')"
	echo "源镜像: $SOURCE"
	echo "digest: $SOURCE_digest"
	echo "目的地: $TARGET"
	echo "digest: $TARGET_digest"

	# 相同则跳过
	if [ -n "$SOURCE_digest" ] && [ -n "$TARGET_digest" ] && [ "$SOURCE_digest" = "$TARGET_digest" ]; then
		echo "✅ 源和目的地内容一致，跳过同步"
		continue
	fi

	# 同步镜像
	echo "🔄 同步镜像"
	if ! crane copy --platform="$PLATFORM" "$SOURCE" "$TARGET"; then
		echo "❌ 镜像同步失败"
		exit 1
	fi
	echo "✅ 同步完成"

done

echo "----------------------------------------"
echo "$(date '+%Y-%m-%d %H:%M:%S')"
echo "🎉 全部镜像同步完成"
echo "----------------------------------------"
exit 0
