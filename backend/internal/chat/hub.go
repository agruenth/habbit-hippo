package chat

import (
	"context"
	"database/sql"
	"encoding/json"
	"log"
	"net/http"
	"sync"
	"time"

	"github.com/google/uuid"
	"github.com/gorilla/websocket"
)

var upgrader = websocket.Upgrader{
	CheckOrigin: func(r *http.Request) bool { return true },
}

type Frame struct {
	Type    string          `json:"type"`
	Payload json.RawMessage `json:"payload,omitempty"`
}

type MessagePayload struct {
	ID         string `json:"id"`
	SenderID   string `json:"sender_id"`
	Content    string `json:"content"`
	SentAt     int64  `json:"sent_at"`
}

type Hub struct {
	mu      sync.RWMutex
	clients map[string]*websocket.Conn // userID → conn
	db      *sql.DB
}

func NewHub(db *sql.DB) *Hub {
	return &Hub{
		clients: make(map[string]*websocket.Conn),
		db:      db,
	}
}

func (h *Hub) ServeWS(userID string) http.HandlerFunc {
	return func(w http.ResponseWriter, r *http.Request) {
		conn, err := upgrader.Upgrade(w, r, nil)
		if err != nil {
			return
		}
		h.mu.Lock()
		h.clients[userID] = conn
		h.mu.Unlock()

		defer func() {
			h.mu.Lock()
			delete(h.clients, userID)
			h.mu.Unlock()
			conn.Close()
		}()

		conn.SetReadDeadline(time.Now().Add(60 * time.Second))
		conn.SetPongHandler(func(string) error {
			conn.SetReadDeadline(time.Now().Add(60 * time.Second))
			return nil
		})

		go func() {
			ticker := time.NewTicker(30 * time.Second)
			defer ticker.Stop()
			for range ticker.C {
				h.mu.RLock()
				c := h.clients[userID]
				h.mu.RUnlock()
				if c == nil {
					return
				}
				if err := c.WriteMessage(websocket.PingMessage, nil); err != nil {
					return
				}
			}
		}()

		for {
			var frame Frame
			if err := conn.ReadJSON(&frame); err != nil {
				break
			}
			conn.SetReadDeadline(time.Now().Add(60 * time.Second))

			switch frame.Type {
			case "ping":
				conn.WriteJSON(Frame{Type: "pong"})
			case "message":
				h.handleMessage(userID, frame.Payload)
			}
		}
	}
}

func (h *Hub) handleMessage(senderID string, raw json.RawMessage) {
	var body struct {
		RecipientID string `json:"recipient_id"`
		Content     string `json:"content"`
	}
	if err := json.Unmarshal(raw, &body); err != nil || body.Content == "" {
		return
	}
	id := uuid.New().String()
	now := time.Now().Unix()
	_, err := h.db.ExecContext(context.Background(),
		`INSERT INTO messages (id, sender_id, recipient_id, content, sent_at) VALUES (?,?,?,?,?)`,
		id, senderID, body.RecipientID, body.Content, now,
	)
	if err != nil {
		log.Printf("insert message: %v", err)
		return
	}
	payload, _ := json.Marshal(MessagePayload{
		ID: id, SenderID: senderID, Content: body.Content, SentAt: now,
	})
	frame := Frame{Type: "message", Payload: payload}

	h.mu.RLock()
	recipientConn := h.clients[body.RecipientID]
	h.mu.RUnlock()

	if recipientConn != nil {
		recipientConn.WriteJSON(frame)
	}
}

// GetMessages returns chat history between two users.
func (h *Hub) GetMessages(ctx context.Context, userID, friendID string, limit int) ([]MessagePayload, error) {
	rows, err := h.db.QueryContext(ctx, `
		SELECT id, sender_id, content, sent_at
		FROM messages
		WHERE (sender_id=? AND recipient_id=?) OR (sender_id=? AND recipient_id=?)
		ORDER BY sent_at DESC LIMIT ?`,
		userID, friendID, friendID, userID, limit,
	)
	if err != nil {
		return nil, err
	}
	defer rows.Close()
	var out []MessagePayload
	for rows.Next() {
		var m MessagePayload
		if err := rows.Scan(&m.ID, &m.SenderID, &m.Content, &m.SentAt); err != nil {
			return nil, err
		}
		out = append(out, m)
	}
	return out, rows.Err()
}

func (h *Hub) SendMessage(ctx context.Context, senderID, recipientID, content string) (MessagePayload, error) {
	id := uuid.New().String()
	now := time.Now().Unix()
	_, err := h.db.ExecContext(ctx,
		`INSERT INTO messages (id, sender_id, recipient_id, content, sent_at) VALUES (?,?,?,?,?)`,
		id, senderID, recipientID, content, now,
	)
	if err != nil {
		return MessagePayload{}, err
	}
	msg := MessagePayload{ID: id, SenderID: senderID, Content: content, SentAt: now}

	payload, _ := json.Marshal(msg)
	h.mu.RLock()
	conn := h.clients[recipientID]
	h.mu.RUnlock()
	if conn != nil {
		conn.WriteJSON(Frame{Type: "message", Payload: payload})
	}
	return msg, nil
}
