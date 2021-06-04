# libguestfs-appliance
This repository contains the setup to build the fixed appliance for libguestfs. A new appliance is built and published weekly at https://storage.googleapis.com/kubevirt-prow/devel/release/kubevirt.

The CI setup that publishes the appliance can be found in the [project-infra](https://github.com/kubevirt/project-infra/tree/master/github/ci/prow-deploy/files/jobs/kubevirt/libguestfs-appliance) and weekly job status in [prow](https://prow.ci.kubevirt.io/?type=periodic&job=periodic-libguestfs-appliance-push-weekly-build-main).

The main goal of this fixed appliance is to be able to correctly build a container image with libguestfs-tools using bazel. The appliance can be fetched during building time by adding it to the WORKSPACE.

Example:
```
http_file(
    name = "libguestfs-appliance",
    sha256 = "1be29201b2622078c90b0f2044d95da23f8f456cd0ed4421cca9b16266962479",
    urls = [
        "https://storage.googleapis.com/kubevirt-prow/devel/release/kubevirt/libguestfs-appliance/appliance-1.44.0-linux-5.11.22-100-fedora32.tar.xz",
    ],
)
```
