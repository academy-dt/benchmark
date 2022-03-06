#!/bin/bash

run_iteration() {
    local iteration="$1"

    local log_dir="$output_dir/$iteration"
    mkdir "$log_dir"

    $cleanup

    declare -r last=$((instances - 1))
    for i in $(seq 0 $last); do
        "$shim" "$i" &>"$log_dir/$i.log" &
        pids[${i}]=$!

        if [[ "$instance_delay" != "X" ]]; then
            sleep "$instance_delay"
        fi
    done

    for pid in ${pids[@]}; do
        wait "$pid" &>/dev/null
    done
}

run_analysis() {
    local iteration="$1"
    echo "Iteration #$iteration: $(./benchmark-average.py "$output_dir/$iteration/*.log")"
}

main() {
    if [[ $# -lt 6 ]]; then
        echo "Usage: $0 <iterations> <iterations-delay> <instances> <instances-delay> <cleanup> <shim>"
        echo ""
        echo "  Delays are specified in second fractions (i.e. 1, 3, 0.125, 2.25, ...)"
        echo "  Or 'X' to avoid any delays"
        echo ""
        return 1
    fi

    declare -r iterations="$1"
    declare -r iteration_delay="$2"
    declare -r instances="$3"
    declare -r instance_delay="$4"
    declare -r cleanup="$5"
    declare -r shim="$6"

    declare -a pids=()

    declare -r output_dir="bench-${iterations}_${iteration_delay}s_iterations-${instances}_${instance_delay}s_instances"
    mkdir "$output_dir" || return 1

    for i in $(seq 1 $iterations); do
        echo "Iteration #$i..."
        run_iteration "$i"

        if [[ "$iteration_delay" != "X" ]]; then
            sleep "$iteration_delay"
        fi
    done

    $cleanup

    for i in $(seq 1 $iterations); do
        run_analysis "$i" | tee "$output_dir/$i.txt"
    done
}

main "$@"
