package handlers

import (
	"encoding/json"
	"log"
	"net/http"
	"text/template"
	"time"

	"github.com/gorilla/websocket"
	"github.com/hackranger/farm-monitor/imagereco"
)

var upgrader = websocket.Upgrader{} // use default options

func Home(w http.ResponseWriter, r *http.Request) {
	homeTemplate, err := template.ParseFiles("template/index.tpl")
	if err != nil {
		log.Println("Unable to parse template")
	}
	homeTemplate.Execute(w, "ws://"+r.Host+"/video")
}

func VideoHandler(w http.ResponseWriter, r *http.Request) {
	ws, err := upgrader.Upgrade(w, r, nil)
	if err != nil {
		log.Print("upgrade:", err)
		return
	}
	defer ws.Close()
	for {
		image := imagereco.GetRecentImage()
		tags := imagereco.GetRecentImageTags()
		ws.WriteMessage(websocket.BinaryMessage, image)
		var jsonData []byte
		jsonData, err := json.Marshal(tags)
		if err != nil {
			log.Println("Unable to marshal tags")
			continue
		}
		ws.WriteMessage(websocket.TextMessage, jsonData)
		time.Sleep(time.Second * 1)
	}
}
