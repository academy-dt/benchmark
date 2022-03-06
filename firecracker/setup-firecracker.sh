#!/bin/bash

install_firecracker() {
    if [[ -f "/usr/local/bin/firecracker" ]]; then
        echo "Firecracker binary already installed"
        return 0
    fi
    echo "Downloading firecracker binary..."

    release_url="https://github.com/firecracker-microvm/firecracker/releases"
    latest="$(basename "$(curl -fsSLI -o /dev/null -w  %{url_effective} ${release_url}/latest)")"
    curl -L "${release_url}/download/${latest}/firecracker-${latest}-${arch}.tgz" | tar -xz

    sudo mv "release-${latest}-${arch}/firecracker-${latest}-${arch}" "/usr/local/bin/firecracker"
}

download_vmlinux() {
    local vmlinux="vmlinux"
    if [[ -f "$vmlinux" ]]; then
        echo "VM image already available"
        return 0
    fi
    echo "Downloading VM image..."

    wget -O "$vmlinux" "$s3/$arch/kernels/vmlinux.bin"
}

download_rootfs() {
    local fs="rootfs.ext4"
    if [[ -f "$fs" ]]; then
        echo "VM filesystem already available"
        return 0
    fi
    echo "Downloading VM filesystem..."

    wget -O "$fs" "$s3/$arch/rootfs/bionic.rootfs.ext4" || return 1
}

main() {
    declare -r s3="https://s3.amazonaws.com/spec.ccfc.min/img/quickstart_guide"
    declare -r arch="$(uname -m)"

    install_firecracker || return 1
    download_vmlinux || return 1
    download_rootfs || return 1

    return 0
}

main "$@"
