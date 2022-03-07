#!/bin/bash

main() {
    if [[ $# -ne 1 ]]; then
        echo "Usage: $0 <id>"
        return 1
    fi

    declare -r id="$1"

    declare -r ip="localhost"
    declare -r base_port="9090"
    declare -r port=$((base_port + id))
    declare -r cmd="docker run --runtime kata -p $port:9090 webd:latest"

    ./benchmark "$cmd" "$ip" "$port"
}

main "$@"
