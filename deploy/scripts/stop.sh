#!/bin/bash
CONTAINER_NAME="cool-vue"
if [ "$(docker ps -aq -f name=${CONTAINER_NAME})" ]; then
    docker stop ${CONTAINER_NAME} || true
    docker rm ${CONTAINER_NAME} || true
fi