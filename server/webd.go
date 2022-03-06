package main

import (
	"fmt"
	"log"
	"net/http"
	"os"
	"strconv"
	"sync/atomic"
)

func main() {
	var request uint64 = 0

	port := 9090
	if len(os.Args) > 1 {
		val, err := strconv.Atoi(os.Args[1])
		if err == nil {
			port = val
		}
	}

	http.HandleFunc("/", func(w http.ResponseWriter, r *http.Request) {
		current := atomic.AddUint64(&request, 1)
		fmt.Fprintf(w, "Request %d", current)
	})

	log.Printf("Running HTTP server on port %d", port)

	hostname := fmt.Sprintf(":%d", port)
	log.Fatal(http.ListenAndServe(hostname, nil))
}
