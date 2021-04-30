FROM fedora:33

env LIBGUESTFS_BACKEND direct

RUN dnf update -y && dnf install --setopt=install_weak_deps=False -y \
    libguestfs  \
    libguestfs-devel \
    && dnf clean all

RUN mkdir -p /output \
    && cd /output \
    && libguestfs-make-fixed-appliance --xz \
    && KERNEL_VERSION=$(rpm -qa  kernel-core | sed 's/kernel-core-\(.*\)\.fc.*/\1/') \
    && LIBGUESTFS_VERSION=$(libguestfs-make-fixed-appliance --version | sed 's/libguestfs-make-fixed-appliance //') \
    && source /etc/os-release \
    && mv appliance-${LIBGUESTFS_VERSION}.tar.xz appliance-${LIBGUESTFS_VERSION}-linux-${KERNEL_VERSION}-${ID}${VERSION_ID}.tar.xz
