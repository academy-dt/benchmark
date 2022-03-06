#!/bin/bash

main() {
    if [[ $# -lt 2 ]]; then
        echo "Usage: <comm> <command>"
	return 1
    fi

    declare -r comm="$1"
    declare -r cmd="${@:2}"
    declare -r log="app.log"

    rm -f "$log" || return 1

    echo "Running $cmd..."
    $cmd &>/dev/null &

    sleep 3

    echo "Monitoring..."
    while pidof "$comm" &>/dev/null; do
        ps -C "$comm" -o pid=,%cpu=,rss=,vsz= >> "$log"
        sleep 1
    done
}

main "$@"
