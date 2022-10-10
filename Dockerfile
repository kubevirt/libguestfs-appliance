FROM quay.io/centos/centos:stream8

ENV LIBGUESTFS_BACKEND direct

# Install centos-release-advanced-virtualization to get the Advanced Virtualization package version
RUN dnf update -y && \
    dnf install -y centos-release-advanced-virtualization && \
    dnf install -y --setopt=install_weak_deps=False \
        libguestfs \
        libguestfs-devel && \
    dnf clean -y all

RUN mkdir -p /output && \
    cd /output && \
    libguestfs-make-fixed-appliance --xz && \
    KERNEL_VERSION=$(rpm -qa kernel-core | sed 's/kernel-core-\(.*\)\.el8.*/\1/') && \
    LIBGUESTFS_VERSION=$(libguestfs-make-fixed-appliance --version | sed 's/libguestfs-make-fixed-appliance //') && \
    source /etc/os-release && \
    mv appliance-${LIBGUESTFS_VERSION}.tar.xz appliance-${LIBGUESTFS_VERSION}-linux-${KERNEL_VERSION}-${ID}${VERSION_ID}.tar.xz && \
    echo "appliance-${LIBGUESTFS_VERSION}-linux-${KERNEL_VERSION}-${ID}${VERSION_ID}" > latest-version.txt
