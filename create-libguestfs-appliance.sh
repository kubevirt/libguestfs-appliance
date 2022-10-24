#!/bin/bash -xe

IMAGE=${IMAGE:-libguestfs-appliance}
VERSION=${VERSION:-$(date +"%y%m%d%H%M")-$(git rev-parse --short HEAD)}
CONT_NAME=extract-libguestfs-appliance
# Select an available container runtime
if [ -z ${RUNTIME} ]; then
    if docker ps >/dev/null; then
        RUNTIME=docker
        echo "selecting docker as container runtime"
    elif podman ps >/dev/null; then
        RUNTIME=podman
        echo "selecting podman as container runtime"
    else
        echo "no working container runtime found. Neither docker nor podman seems to work."
        exit 1
    fi
fi


${RUNTIME} build --build-arg VERSION=${VERSION} --rm -t ${IMAGE} .
${RUNTIME} create --name ${CONT_NAME} ${IMAGE} sh
${RUNTIME} cp ${CONT_NAME}:/output .
${RUNTIME} rm ${CONT_NAME}
