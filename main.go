package main

import (
	"fmt"
	"log"
	"net/http"
	"os"

	"github.com/gorilla/websocket"
	"github.com/rs/cors"
)

var clients = make(map[*websocket.Conn]bool)
var broadcast = make(chan Message)

type Message struct {
	Name    string `json:"name"`
	Message string `json:"message"`
}

var upgrader = websocket.Upgrader{
	CheckOrigin: func(r *http.Request) bool {
		return true
	},
}

func main() {
	port := os.Getenv("PORT")
	if port == "" {
		port = "7070"
	}

	mux := http.NewServeMux()

	mux.HandleFunc("/", func(w http.ResponseWriter, r *http.Request) {
		w.WriteHeader(200)
		w.Write([]byte("Hello"))
	})

	mux.HandleFunc("/ws", Websocket)

	go handleMessages()

	handler := cors.Default().Handler(mux)
	err := http.ListenAndServe(":"+port, handler)
	if err != nil {
		log.Fatal("Listen and serve err: ", err)
	}
}

func Websocket(w http.ResponseWriter, r *http.Request) {
	ws, err := upgrader.Upgrade(w, r, nil)
	if err != nil {
		log.Fatal(err)
	}

	defer ws.Close()

	clients[ws] = true
	fmt.Println("Connected")

	for {
		var msg Message
		err := ws.ReadJSON(&msg)
		fmt.Println(msg)
		if err != nil {
			log.Printf("error: %s", err)
			delete(clients, ws)
			break
		}

		broadcast <- msg
	}
}

func handleMessages() {
	for {
		msg := <-broadcast
		for client := range clients {
			err := client.WriteJSON(msg)
			if err != nil {
				log.Printf("error : %s", err)
				client.Close()
				delete(clients, client)
			}
		}
	}
}
