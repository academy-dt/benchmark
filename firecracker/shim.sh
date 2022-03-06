#!/bin/bash

main() {
    if [[ $# -ne 1 ]]; then
        echo "Usage: $0 <id>"
        return 1
    fi

    declare -r id="$1"

    declare -r cmd="./run-firecracker.sh $id"
    declare -r ip="$(printf '169.254.%s.%s' $(((4 * id + 1) / 256)) $(((4 * id + 1) % 256)))"
    declare -r port="9090"

    ./benchmark "$cmd" "$ip" "$port"
}

main "$@"
