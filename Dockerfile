FROM quay.io/centos/centos:stream9

ENV LIBGUESTFS_BACKEND direct

RUN dnf update -y && \
    dnf install -y --setopt=install_weak_deps=False \
        libguestfs \
        libguestfs-winsupport \
        qemu-img && \
    dnf clean -y all

# Create tarball for the appliance. This fixed libguestfs appliance uses the root in qcow2 format as container runtime not always handle correctly sparse files. This appliance can be extracted and copied directly in the container image.
RUN mkdir -p /output && \
    mkdir -p /appliance && \
    libguestfs-make-fixed-appliance /appliance && \
    cd /appliance && \
    qemu-img convert -c -O qcow2 root root.qcow2 && \
    mv root.qcow2 root

COPY BUILD /appliance/BUILD

RUN KERNEL_VERSION=$(rpm -qa kernel-core | sed 's/kernel-core-\(.*\)\.el9.*/\1/') && \
    LIBGUESTFS_VERSION=$(libguestfs-make-fixed-appliance --version | sed 's/libguestfs-make-fixed-appliance //') && \
    source /etc/os-release && \
    APPLIANCE_NAME=libguestfs-appliance-${LIBGUESTFS_VERSION}-qcow2-linux-${KERNEL_VERSION}-${ID}${VERSION_ID}.tar.xz && \
    cd /output && \
    tar -cJvf ${APPLIANCE_NAME} /appliance && \
    echo ${APPLIANCE_NAME} > latest-version.txt
