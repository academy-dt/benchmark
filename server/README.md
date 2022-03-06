# Minimal, statically-compiled web-server in Go

A minimal web-server in Go.
Registers a single GET handler for the root (`/`) path.

Answers every GET with `Request #<request-no>` (Where the request number is an auto-incremented atomic variable).

## Compilation

Compile using `go build -tags netgo` to [avoid all CGO dependencies from the net package](https://www.arp242.net/static-go.html).

## Execution

Run using `./webd <port-number>` (Default port is 9090).

## Installation

Most examples in this benchmarking effort assume `webd` is globally accessible.
This is easily achievable by running `sudo cp webd /usr/local/bin/.`.

## Register for startup

To register the `webd` to run on startup, we will wrap it using a minimal SysV service script - `web`.

First, copy the script into `/etc/init.d/` using the command: `sudo cp web /etc/init.d/.`.
Then, tell the OS to boot the `web` service on [multi-user run-levels](https://www.techtarget.com/searchdatacenter/definition/runlevel) using:
```
for rc in $(seq 3 5); do ln -s ../init.d/web /etc/rc${rc}.d/S99web; done
```