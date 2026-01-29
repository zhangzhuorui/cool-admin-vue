#!/bin/bash
source /opt/app/vue_env.file

CONTAINER_NAME="cool-vue"

echo "Stopping old frontend container..."
docker stop ${CONTAINER_NAME} || true
docker rm ${CONTAINER_NAME} || true

echo "Starting new frontend container on port 80..."
# 将容器的 80 端口映射到宿主机的 80 端口
docker run -d \
  --name ${CONTAINER_NAME} \
  --restart unless-stopped \
  -p 80:80 \
  ${VUE_IMAGE}

echo "Frontend deployment finished!"