package main

import (
	"encoding/json"
	"fmt"
	"log"
	"net/http"
	"os"
	"strconv"

	"github.com/gorilla/websocket"
	"github.com/rs/cors"
)

var channels = make(map[int]*Channel)
var chatsId = 0

type Channel struct {
	ID       int                      `json:"id"`
	Upgrader *websocket.Upgrader      `json:"upgrader"`
	Name     string                   `json:"name"`
	Users    map[*websocket.Conn]bool `json:"users"`
	Messages chan Message             `json:"Messages"`
}

type Message struct {
	Name    string `json:"name"`
	Message string `json:"message"`
}

type RespChannel struct {
	ID   int    `json:"id"`
	Name string `json:"string"`
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
		fmt.Println("here")
		fmt.Println(channels)
		var channelsArr []RespChannel
		for _, ch := range channels {
			var respC RespChannel
			respC.ID = ch.ID
			respC.Name = ch.Name
			channelsArr = append(channelsArr, respC)
		}
		fmt.Println(channelsArr)
		json, _ := json.Marshal(channelsArr)
		fmt.Println(json)
		w.WriteHeader(200)
		w.Write([]byte(json))
	})

	mux.HandleFunc("/ws", Websocket)

	handler := cors.Default().Handler(mux)
	err := http.ListenAndServe(":"+port, handler)
	if err != nil {
		log.Fatal("Listen and serve err: ", err)
	}
}

func Websocket(w http.ResponseWriter, r *http.Request) {
	fmt.Println("new connection")

	r.ParseForm()
	if r.FormValue("id") == "" {
		newID := chatsId
		strid := strconv.Itoa(chatsId)
		chatName := "chat " + strid
		newChannel := Channel{}
		newChannel.ID = newID
		newChannel.Name = chatName
		newChannel.Upgrader = &websocket.Upgrader{}
		newChannel.Users = make(map[*websocket.Conn]bool)
		newChannel.Messages = make(chan Message)
		ws, _ := newChannel.Upgrader.Upgrade(w, r, nil)
		newChannel.Users[ws] = true
		channels[newID] = &newChannel

		go channels[newID].handleMessages()
		go handleConnections(w, r, ws, newID)
		chatsId++

		//create new cahnnel
	} else {
		id, err := strconv.Atoi(r.FormValue("id"))
		if err != nil {
			w.WriteHeader(http.StatusBadRequest)
			return
		}
		ws, _ := channels[id].Upgrader.Upgrade(w, r, nil)
		channels[id].Users[ws] = true
		go handleConnections(w, r, ws, id)

	}
}

func handleConnections(w http.ResponseWriter, r *http.Request, ws *websocket.Conn, id int) {

	for {
		var msg Message
		fmt.Println(msg)
		// Read in a new message as JSON and map it to a Message object
		err := ws.ReadJSON(&msg)
		if err != nil {
			log.Printf("error: %v", err)
			delete(channels[id].Users, ws)
			break
		}
		// Send the newly received message to the broadcast channel
		channels[id].Messages <- msg
	}
}

func (ch *Channel) handleMessages() {
	for {
		msg := <-ch.Messages
		for client := range ch.Users {
			err := client.WriteJSON(msg)
			if err != nil {
				log.Printf("error : %s", err)
				client.Close()
				delete(ch.Users, client)
			}
		}
	}
}
