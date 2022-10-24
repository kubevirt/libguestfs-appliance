# libguestfs-appliance
This repository contains the setup to build the fixed appliance for libguestfs. A new appliance is built and published weekly at https://storage.googleapis.com/kubevirt-prow/devel/release/kubevirt.

The CI setup that publishes the appliance can be found in the [project-infra](https://github.com/kubevirt/project-infra/tree/master/github/ci/prow-deploy/files/jobs/kubevirt/libguestfs-appliance) and weekly job status in [prow](https://prow.ci.kubevirt.io/?type=periodic&job=periodic-libguestfs-appliance-push-weekly-build-main). The latest version of the published appliance can be found by querying: `curl -L https://storage.googleapis.com/kubevirt-prow/devel/release/kubevirt/libguestfs-appliance/latest-version.txt`.

The main goal of this fixed appliance is to be able to correctly build a container image with libguestfs-tools using bazel. The appliance can be fetched during building time by adding it to the WORKSPACE.

Example:
```
http_file(
    name = "libguestfs-appliance",
    sha256 = "0e1d08363ddfb185f08b8d357b6a91bd5ca8f19455a2ca7e74bfd2c9990a0235",
    urls = [
        "https://storage.googleapis.com/kubevirt-prow/devel/release/kubevirt/libguestfs-appliance/libguestfs-appliance-2210241731-1df853a.tar.xz",
    ],
)
```
