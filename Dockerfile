FROM quay.io/centos/centos:stream9

ARG VERSION

ENV LIBGUESTFS_BACKEND direct

RUN dnf update -y && \
    dnf install -y dnf-plugins-core && \
    dnf config-manager --enable crb && \
    dnf install -y --setopt=install_weak_deps=False \
        libguestfs \
        libguestfs-devel && \
    dnf clean -y all

RUN mkdir -p /output && \
    cd /output && \
    libguestfs-make-fixed-appliance --xz && \
    LIBGUESTFS_VERSION=$(libguestfs-make-fixed-appliance --version | sed 's/libguestfs-make-fixed-appliance //') && \
    APPLIANCE_NAME=libguestfs-appliance-${VERSION}.tar.xz && \
    mv appliance-${LIBGUESTFS_VERSION}.tar.xz ${APPLIANCE_NAME} && \
    echo ${APPLIANCE_NAME} > latest-version.txt
