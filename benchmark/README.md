# Web-server benchmarking utility

A set of simple benchmarking utilities that build on top of each other.

## Single instance benchmark tool

A simple Go application that starts a web-server (wrapped in any possible way),
and measures the time until it first answers a GET request.

### Compile

Simply run `go build`.

### Use

```
Usage: ./benchmark <server-cmd> <server-ip> <server-port>
    server-cmd      How to run the web-server. Executed in a separate child, hence allowed to block
    server-ip       The IP of the web-server. Where to send the GET request
    server-port     The port of the web-server. Where to send the GET request
```

Output is a single string, for example: `2022/03/06 17:24:06 [9090] First response in 4 ms`.

## Multiple instance benchmarking tool

A small bash script that wraps the `benchmark` executable.

To eliminate background noises, one should always run multiple benchmarks and average those out.
In an attempt to automate our benchmarking efforts,
we are using the `benchmark-multiple.sh` script to run X benchmarking iterations with Y instances for each benchmark.
The script allows us to configure specific cleanup operations and delays between iterations.

Arguments:
`Usage: ./benchmark-multiple.sh <iterations> <iterations-delay> <instances> <instances-delay> <cleanup> <shim>`

The entire flow is:
1. Run pre-execution cleanup
1. For i in 1..X
    1. For j in 1..Y:
        1. Start instance #
        1. Wait `instance-delay` seconds
    1. Run post-iteration cleanup
    1. Wait `iteration-delay` seconds

The only requirement, is to provide a shim script around the benchmark app.
The shim script is expected to take a single instance ID value,
and executes the benchmark tool with the right paramters (preventing any collisions).

## Average calculation

A utility script, `benchmark-average.py`, allows you to easily calculate the average response time.
When running the benchmark utility, redirect the output into a file, i.e. `./benchmark [ARGS]... &> <port>.log`.

Then, calculate the average time from all the executions using: `./benchmark-average.py '*.log'`.

Notes:
- The argument is a glob, use any glob expression you want
- Make sure to wrap any expression using single quotes to prevent the shell from expanding those
