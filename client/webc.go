package main

import (
	"fmt"
	"io/ioutil"
	"net/http"
	"os"
	"strconv"
	"time"
)

func printResponse(r *http.Response) {
	bodyBytes, err := ioutil.ReadAll(r.Body)
	if err != nil {
		fmt.Printf("Read Err: %s", err)
		return
	}

	bodyString := string(bodyBytes)
	fmt.Printf("%s\n", bodyString)
}

func get(client *http.Client, url string) int {
	r, err := client.Get(url)
	if err != nil {
		fmt.Printf("GET Err: %s\n", err)
		return 1
	}
	defer r.Body.Close()

	if r.StatusCode != http.StatusOK {
		fmt.Printf("Status Err: %d\n", r.StatusCode)
		return 1
	}

	return 0
}

func run(url string, sleep int) {
	var total int64 = 0
	var success int64 = 0

	transport := &http.Transport{}
	client := &http.Client{Transport: transport}

	start := time.Now()
	last := start
	for {
		if get(client, url) != 0 {
			break
		}
		success += 1

		if sleep != 0 {
			time.Sleep(time.Duration(sleep) * time.Millisecond)
		}

		now := time.Now()
		if now.Sub(last) >= time.Second {
			fmt.Printf("TPS: %d\n", success)
			total += success
			success = 0
			last = now
		}
	}

	now := time.Now()
	ms := int64(now.Sub(start) / time.Millisecond)
	fmt.Printf("Total: %d in %d ms (%f T/ms)\n", total, ms, float32(total)/float32(ms))
}

func usage() {
	fmt.Printf("Usage: %s <url> <sleep(ms)>\n", os.Args[0])
	os.Exit(1)
}

func main() {
	if len(os.Args) != 3 {
		usage()
	}

	url := os.Args[1]

	sleep, err := strconv.Atoi(os.Args[2])
	if err != nil {
		usage()
	}

	run(url, sleep)
}
