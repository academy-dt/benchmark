#!/bin/bash -e

main() {
    if [[ $UID != 0 ]]; then
        echo "Please run as a privileged user"
        return 1
    fi

    declare -r tap_dev="$1"
    declare -r tap_net="$2" # ip/mask

    ip link del "$tap_dev" 2> /dev/null || true

    if ! ip tuntap add dev "$tap_dev" mode tap; then
        echo "Failed to create tap $tap_dev"
        return 1
    fi

    if ! sysctl -w "net.ipv4.conf.${tap_dev}.proxy_arp=1" > /dev/null; then
        echo "Failed to setup proxy ARP"
        return 1
    fi

    if ! sysctl -w "net.ipv6.conf.${tap_dev}.disable_ipv6=1" > /dev/null; then
        echo "Failed to disable IPv6"
        return 1
    fi

    if ! ip addr add "${tap_net}" dev "$tap_dev"; then
        echo "Failed to add IP [${tap_net}] to tap [$tap_dev]"
        return 1
    fi

    if ! ip link set dev "$tap_dev" up; then
        echo "Failed to enable tap [$tap_dev]"
        return 1
    fi

    return 0
}

main "$@"
