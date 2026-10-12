ARG BUILD_ARCH
FROM --platform=linux/${BUILD_ARCH} quay.io/centos/centos:stream9

ARG BUILD_ARCH
ENV LIBGUESTFS_BACKEND=direct
ENV BUILD_ARCH=${BUILD_ARCH}

RUN 0<<'run-EOF' /bin/bash
set -euxo pipefail; shopt -s inherit_errexit

. /etc/os-release
typeset verMjr="${VERSION_ID%%.*}"
typeset pkgsFile='' e=''
typeset -a epelRPMs=(
    "https://dl.fedoraproject.org/pub/epel/epel-release-latest-${verMjr}.noarch.rpm"
)
typeset -a extraPkgs=(
    ntfs-3g
)

case "${ID}:${verMjr}" in
  (centos:9|centos:10)  ;;
  (*)
    printf 'Unsupported base OS: %s %s\n' "${ID}" "${VERSION_ID}" 1>&2
    exit 1
    ;;
esac
# CentOS Stream 9 also uses EPEL Next; Stream 10 does not.
if [ "${verMjr}" = 9 ]; then
    epelRPMs+=(
        "https://dl.fedoraproject.org/pub/epel/epel-next-release-latest-${verMjr}.noarch.rpm"
    )
fi

dnf -y update --setopt=install_weak_deps=False
dnf -y install dnf-plugins-core
dnf config-manager --set-enabled crb
dnf -y install "${epelRPMs[@]}"
dnf -y install --setopt=install_weak_deps=False libguestfs qemu-img "${extraPkgs[@]}"

# Select extra packages for the generated appliance, not just the builder.
pkgsFile="$(rpm --eval '%{_libdir}')/guestfs/supermin.d/packages"
test -f "${pkgsFile}"
for e in "${extraPkgs[@]}"; do
    if ! grep -qxF "${e}" "${pkgsFile}"; then
        printf '%s\n' "${e}" >> "${pkgsFile}"
    fi
done

dnf -y clean all
run-EOF

# Create tarball for the appliance. This fixed libguestfs appliance uses the root in qcow2 format as container runtime not always handle correctly sparse files. This appliance can be extracted and copied directly in the container image.
RUN mkdir -p /output && \
    mkdir -p /appliance && \
    libguestfs-make-fixed-appliance /appliance && \
    cd /appliance && \
    qemu-img convert -c -O qcow2 root root.qcow2 && \
    mv root.qcow2 root && \
    # Purge stale build-time KVM test cache before committing this layer:
    rm -rf /var/tmp/.guestfs-* /root/.cache/guestfs* /tmp/libguestfs*

COPY BUILD /appliance/BUILD

RUN KERNEL_VERSION=$(rpm -qa kernel-core | sed 's/kernel-core-\(.*\)\.el[0-9]\+.*/\1/') && \
    LIBGUESTFS_VERSION=$(libguestfs-make-fixed-appliance --version | sed 's/libguestfs-make-fixed-appliance //') && \
    source /etc/os-release && \
    APPLIANCE_NAME=libguestfs-appliance-${LIBGUESTFS_VERSION}-qcow2-linux-${KERNEL_VERSION}-${ID}${VERSION_ID}-${BUILD_ARCH}.tar.xz && \
    cd /output && \
    tar -cJvf ${APPLIANCE_NAME} /appliance && \
    echo ${APPLIANCE_NAME} > latest-version-${BUILD_ARCH}.txt
