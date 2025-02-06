#!/bin/bash

IMAGES=(
    "hello-world registry.cn-hangzhou.aliyuncs.com/blazesnow/hello-world"
    "fauria/vsftpd registry.cn-hangzhou.aliyuncs.com/blazesnow/vsftpd"
    "atmoz/sftp registry.cn-hangzhou.aliyuncs.com/blazesnow/sftp"
    "bytemark/webdav registry.cn-hangzhou.aliyuncs.com/blazesnow/webdav"
    "dockurr/samba registry.cn-hangzhou.aliyuncs.com/blazesnow/samba"
    "xhofe/alist registry.cn-hangzhou.aliyuncs.com/blazesnow/alist"
    "itsthenetwork/nfs-server-alpine registry.cn-hangzhou.aliyuncs.com/blazesnow/nfs-server-alpine"
    "itzg/minecraft-server registry.cn-hangzhou.aliyuncs.com/blazesnow/minecraft-server"
    "adguard/adguardhome registry.cn-hangzhou.aliyuncs.com/blazesnow/adguardhome"
    "vaultwarden/server registry.cn-hangzhou.aliyuncs.com/blazesnow/vaultwarden_server"
    "nginx registry.cn-hangzhou.aliyuncs.com/blazesnow/nginx"
    "lanol/filecodebox registry.cn-hangzhou.aliyuncs.com/blazesnow/filecodebox"
    "binwiederhier/ntfy registry.cn-hangzhou.aliyuncs.com/blazesnow/ntfy"
    "homeassistant/home-assistant registry.cn-hangzhou.aliyuncs.com/blazesnow/home-assistant"
    "teamspeak registry.cn-hangzhou.aliyuncs.com/blazesnow/teamspeak"
)

for IMAGE_PAIR in "${IMAGES[@]}"; do
    SOURCE_IMAGE=$(echo "$IMAGE_PAIR" | awk '{print $1}')
    TARGET_IMAGE=$(echo "$IMAGE_PAIR" | awk '{print $2}')

    echo "Processing $SOURCE_IMAGE -> $TARGET_IMAGE"
    docker pull "$SOURCE_IMAGE"
    if [ $? -ne 0 ]; then
        echo "Failed to pull $SOURCE_IMAGE"
        continue
    fi

    docker tag "$SOURCE_IMAGE" "$TARGET_IMAGE"
    if [ $? -ne 0 ]; then
        echo "Failed to tag $SOURCE_IMAGE as $TARGET_IMAGE"
        continue
    fi

    docker push "$TARGET_IMAGE"
    if [ $? -ne 0 ]; then
        echo "Failed to push $TARGET_IMAGE"
        continue
    fi

    docker rmi -f "$SOURCE_IMAGE" "$TARGET_IMAGE"
    if [ $? -ne 0 ]; then
        echo "Failed to remove images for $SOURCE_IMAGE and $TARGET_IMAGE"
    fi

    echo "Done with $SOURCE_IMAGE -> $TARGET_IMAGE"
    echo "-------------------------------------"
done

echo "All images processed and cleaned up!"
