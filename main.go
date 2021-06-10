package main

import (
	"log"
	"net/http"

	"github.com/hackranger/farm-monitor/handlers"
	"github.com/hackranger/farm-monitor/imagereco"
)

func main() {
	log.SetFlags(log.LstdFlags | log.Lshortfile)
	// init image recognition
	imagereco.InitImageRecognition()

	// Run image recognition in backgroud
	go imagereco.StartImageRecognitionAndTagging()

	http.Handle("/static/", http.StripPrefix("/static/", http.FileServer(http.Dir("static"))))
	http.HandleFunc("/video", handlers.VideoHandler)
	http.HandleFunc("/", handlers.Home)

	log.Fatal(http.ListenAndServe("localhost:8000", nil))
}
