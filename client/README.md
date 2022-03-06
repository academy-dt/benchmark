# Minimal, web-client in Go

A minimal web-client in Go.
Sends GET requests to the specified URL, with a configurable delay (in ms) between consecutive requests, and reports the TPS every second.

## Compilation

Compile using `go build`.

## Execution

Run using `./webc <server-url> <delay(ms)>`.