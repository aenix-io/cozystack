package main

import (
	"flag"
	"log"
	"net/http"
	"path/filepath"
)

func main() {
	addr := flag.String("address", ":8123", "Address to listen on")
	dir := flag.String("dir", "/cozystack/assets", "Directory to serve files from")
	flag.Parse()

	absDir, err := filepath.Abs(*dir)
	if err != nil {
		log.Fatalf("Error getting absolute path for %s: %v", *dir, err)
	}

	fs := http.FileServer(http.Dir(absDir))
	http.Handle("/", fs)

	log.Printf("Server starting on %s, serving directory %s", *addr, absDir)

	err = http.ListenAndServe(*addr, nil)
	if err != nil {
		log.Fatalf("Server failed to start: %v", err)
	}
}
