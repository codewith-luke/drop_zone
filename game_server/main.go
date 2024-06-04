package main

import (
	"encoding/json"
	"fmt"
	"github.com/gorilla/websocket"
	"log"
	"net/http"
	"os"
	"os/signal"
	"strings"
	"time"
)

const (
	MessageTypeSystem    = "system"
	MessageTypeUserClick = "click"
)

type MessageType struct {
	Type string `json:"type"`
}

type SystemMessage struct {
	Message string `json:"message"`
	Channel int    `json:"channel"`
	Version string `json:"version"`
}

type UserClickMessage struct {
	Id string `json:"id"`
	X  string `json:"x"`
	Y  string `json:"y"`
}

var wsServer *websocket.Conn

var upgrader = websocket.Upgrader{
	ReadBufferSize:  1024,
	WriteBufferSize: 1024,
}

const (
	CHANNEL_ID = 44420434
)

func main() {
	interrupt := make(chan os.Signal, 1)
	signal.Notify(interrupt, os.Interrupt)

	heatmapConn := createHeatmapConnection()

	done := make(chan struct{})
	defer heatmapConn.Close()

	go func() {
		setupAPI()
	}()

	go func(conn *websocket.Conn) {
		defer close(done)
		handleMessage(conn)
	}(heatmapConn)

	ticker := time.NewTicker(time.Second * 10)
	defer ticker.Stop()

	for {
		select {
		case <-done:
			return
		case t := <-ticker.C:
			fmt.Printf("tick at %v\n", t.String())
			err := heatmapConn.WriteMessage(websocket.TextMessage, []byte(t.String()))

			if err != nil {
				log.Println("write:", err)
				return
			}
		case <-interrupt:
			log.Println("interrupt")

			err := heatmapConn.WriteMessage(websocket.CloseMessage, websocket.FormatCloseMessage(websocket.CloseNormalClosure, ""))

			if err != nil {
				log.Println("write close:", err)
				return
			}
			select {
			case <-done:
			case <-time.After(time.Second):
			}
			return
		}
	}
}

func setupAPI() {
	// TODO: probs good idea to use a channel to check that the server started
	http.Handle("/", http.FileServer(http.Dir("./frontend")))
	http.HandleFunc("/ws", func(writer http.ResponseWriter, request *http.Request) {
		wsServer = websocketHandler(writer, request)
	})
	err := http.ListenAndServe(":8081", nil)

	if err != nil {
		log.Fatal("listenAndServe: ", err)
	}
}

func createHeatmapConnection() *websocket.Conn {
	url := fmt.Sprintf("wss://heat-api.j38.net/channel/%d", CHANNEL_ID)
	heatmapConn, _, err := websocket.DefaultDialer.Dial(url, nil)

	if err != nil {
		log.Fatal(err)
	}

	return heatmapConn
}

func handleMessage(ws *websocket.Conn) {
	for {
		_, message, err := ws.ReadMessage()

		if err != nil {
			log.Println("Error reading message:", err)
			continue
		}

		if len(message) == 0 {
			continue
		}

		err = decodeMessage(message)

		if err != nil {
			log.Println("Error decoding message:", err)
		}
	}
}

func decodeMessage(msg []byte) error {
	msg = []byte(strings.Trim(string(msg), "\x00"))

	var message MessageType

	if err := json.Unmarshal(msg, &message); err != nil {
		log.Printf("error decoding message: %v", err)
		return nil
	}

	switch message.Type {
	case MessageTypeSystem:
		var systemMessage SystemMessage

		if err := json.Unmarshal(msg, &systemMessage); err != nil {
			log.Printf("error decoding message: %v", err)
			return nil
		}

		fmt.Printf("System message: %s\n", systemMessage.Message)
	case MessageTypeUserClick:
		var userClickMessage UserClickMessage

		if err := json.Unmarshal(msg, &userClickMessage); err != nil {
			log.Printf("error decoding message: %v", err)
			return nil
		}

		if wsServer != nil {
			if err := wsServer.WriteMessage(1, msg); err != nil {
				log.Println("Error writing message:", err)
				return nil
			}

			fmt.Printf("forwarded message: %s\n", string(msg))
		}
	}

	return nil
}

func websocketHandler(w http.ResponseWriter, r *http.Request) *websocket.Conn {
	conn, err := upgrader.Upgrade(w, r, nil)

	if err != nil {
		log.Println("Error upgrading to WebSocket:", err)
		return nil
	}

	return conn
}
