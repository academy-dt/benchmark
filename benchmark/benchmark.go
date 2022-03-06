package main

import (
	"log"
    "os/exec"
	"net/http"
	"os"
    "fmt"
	"time"
    "strings"
)

func get(url string) int {
	r, err := http.Get(url)
	if err != nil {
		return 1
	}
	defer r.Body.Close()

	if r.StatusCode != http.StatusOK {
		return 1
	}

	return 0
}

func benchmark(cmd string, ip string, port string) {
    url := fmt.Sprintf("http://%s:%s", ip, port)

    args := strings.Split(cmd, " ")
    child := exec.Command(args[0], args[1:]...)

	start := time.Now()

    err := child.Start()
    if err != nil {
        log.Printf("Exec failed: %s\n", err)
        return
    }

	for get(url) != 0 {
        time.Sleep(1 * time.Millisecond)
    }

    ms := time.Now().Sub(start) / time.Millisecond
	log.Printf("[%s] First response in %d ms\n", port, ms)
}

func main() {
	if len(os.Args) != 4 {
        fmt.Printf("Usage: %s <server-cmd> <server-ip> <server-port>\n", os.Args[0])
        fmt.Printf("    server-cmd      How to run the web-server. Executed in a separate child, hence allowed to block\n");
        fmt.Printf("    server-ip       The IP of the web-server. Where to send the GET request\n");
        fmt.Printf("    server-port     The port of the web-server. Where to send the GET request\n");
        os.Exit(1)
	}

	cmd := os.Args[1]
    ip := os.Args[2]
    port := os.Args[3]

	benchmark(cmd, ip, port)
}

