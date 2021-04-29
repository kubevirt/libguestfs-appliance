FROM fedora:33

env LIBGUESTFS_BACKEND direct

RUN dnf update -y && dnf install --setopt=install_weak_deps=False -y \
    libguestfs  \
    libguestfs-devel \
    && dnf clean all

RUN mkdir -p /output \
    && cd /output \
    && libguestfs-make-fixed-appliance --xz
