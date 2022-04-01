FROM quay.io/centos/centos:stream8

env LIBGUESTFS_BACKEND direct

# Install centos-release-advanced-virtualization to get the Advanced Virtualization package version
RUN yum update -y && yum install -y centos-release-advanced-virtualization && yum update \
    && yum install --setopt=install_weak_deps=False -y \
    libguestfs  \
    libguestfs-devel \
    && yum clean all

# Create tarball for the appliance. This fixed libguestfs appliance uses the root in qcow2 format as container runtime not always handle correctly sparse files. This appliance can be extracted and copied directly in the container image.
RUN mkdir -p /output \
    mkdir -p /appliance \
    && libguestfs-make-fixed-appliance /appliance \
    && cd /appliance \
    && mv root root.raw \
    && qemu-img convert -c -O qcow2 root.raw root \
    && rm root.raw \
    && KERNEL_VERSION=$(rpm -qa  kernel-core | sed 's/kernel-core-\(.*\)\.el8.*/\1/') \
    && LIBGUESTFS_VERSION=$(libguestfs-make-fixed-appliance --version | sed 's/libguestfs-make-fixed-appliance //') \
    && source /etc/os-release \
    && cd /output \
    &&  tar -czvf  appliance-${LIBGUESTFS_VERSION}-linux-${KERNEL_VERSION}-${ID}${VERSION_ID}.tar.gz /appliance \
    && echo "appliance-${LIBGUESTFS_VERSION}-linux-${KERNEL_VERSION}-${ID}${VERSION_ID}" > latest-version.txt
