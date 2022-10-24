FROM quay.io/centos/centos:stream9

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
    KERNEL_VERSION=$(rpm -qa kernel-core | sed 's/kernel-core-\(.*\)\.el9.*/\1/') && \
    LIBGUESTFS_VERSION=$(libguestfs-make-fixed-appliance --version | sed 's/libguestfs-make-fixed-appliance //') && \
    source /etc/os-release && \
    mv appliance-${LIBGUESTFS_VERSION}.tar.xz appliance-${LIBGUESTFS_VERSION}-linux-${KERNEL_VERSION}-${ID}${VERSION_ID}.tar.xz && \
    echo "appliance-${LIBGUESTFS_VERSION}-linux-${KERNEL_VERSION}-${ID}${VERSION_ID}.tar.xz" > latest-version.txt
