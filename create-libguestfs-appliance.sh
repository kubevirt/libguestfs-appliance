#!/bin/bash -xe

ARCHS="amd64 s390x"
IMAGE=${IMAGE:-libguestfs-appliance}
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

for arch in $ARCHS; do 
    ${RUNTIME} build --build-arg BUILD_ARCH="${arch}" --platform "linux/${arch}" --rm -t ${IMAGE}  .
    ${RUNTIME} create --name ${CONT_NAME} ${IMAGE} sh
    ${RUNTIME} cp ${CONT_NAME}:/output .
    ${RUNTIME} rm ${CONT_NAME}
done
