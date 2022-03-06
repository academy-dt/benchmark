#!/bin/bash

main() {
    if [[ $# -ne 1 ]]; then
        echo "Usage: $0 <id>"
        return 1
    fi

    declare -r id="$1"
    declare -r socket="/tmp/firecracker-$id.socket"

    declare -r binary="firecracker"

    declare -r tap_dev="tap${id}"

    declare -r guest_ip="$(printf '169.254.%s.%s' $(((4 * id + 1) / 256)) $(((4 * id + 1) % 256)))"
    declare -r tap_ip="$(printf '169.254.%s.%s' $(((4 * id + 2) / 256)) $(((4 * id + 2) % 256)))"
    declare -r tap_mac="$(printf '02:FC:00:00:%02X:%02X' $((id / 256)) $((id % 256)))"

    declare -r tap_mask_short="/30"
    declare -r tap_mask_long="255.255.255.252"

    declare -r config_dir="config"
    if [[ ! -d "$config_dir" ]]; then
        mkdir "$config_dir"
    fi

    declare -r config_file="$config_dir/config-$id.json"
    declare -r config=""\
"{
  \"boot-source\": {
    \"kernel_image_path\": \"vmlinux\",
    \"boot_args\": \"keep_bootcon console=ttyS0 reboot=k panic=1 pci=off ip=$guest_ip::$tap_ip:$tap_mask_long::eth0:off\"
  },
  \"drives\": [
    {
      \"drive_id\": \"rootfs\",
      \"path_on_host\": \"rootfs.ext4\",
      \"is_root_device\": true,
      \"is_read_only\": false
    }
  ],
  \"network-interfaces\": [
    {
      \"iface_id\": \"eth0\",
      \"guest_mac\": \"$tap_mac\",
      \"host_dev_name\": \"$tap_dev\"
    }
  ],
  \"machine-config\": {
    \"vcpu_count\": 1,
    \"mem_size_mib\": 128
  }
}"

    echo "$config" > "$config_file"

    sudo ./setup-tap.sh "$tap_dev" "$tap_ip$tap_mask_short" || return 1

    rm -f "$socket" || return 1
    "$binary" --api-sock "$socket" --config-file "$config_file"
}

main "$@"
