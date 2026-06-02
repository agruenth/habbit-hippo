package chat

import (
	"encoding/json"
	"net/http"
	"strconv"

	"github.com/go-chi/chi/v5"
	"github.com/agruenth/habbit-hippo/backend/internal/apperr"
	"github.com/agruenth/habbit-hippo/backend/internal/auth"
)

func HandleGetMessages(hub *Hub) http.HandlerFunc {
	return func(w http.ResponseWriter, r *http.Request) {
		userID := auth.UserIDFromCtx(r.Context())
		friendID := chi.URLParam(r, "friendID")
		limit := 50
		if l := r.URL.Query().Get("limit"); l != "" {
			if n, err := strconv.Atoi(l); err == nil && n > 0 {
				limit = n
			}
		}
		msgs, err := hub.GetMessages(r.Context(), userID, friendID, limit)
		if err != nil {
			apperr.Write(w, apperr.ErrInternal)
			return
		}
		w.Header().Set("Content-Type", "application/json")
		json.NewEncoder(w).Encode(msgs)
	}
}

func HandleSendMessage(hub *Hub) http.HandlerFunc {
	type req struct {
		Content string `json:"content"`
	}
	return func(w http.ResponseWriter, r *http.Request) {
		userID := auth.UserIDFromCtx(r.Context())
		friendID := chi.URLParam(r, "friendID")
		var body req
		if err := json.NewDecoder(r.Body).Decode(&body); err != nil || body.Content == "" {
			apperr.BadRequest(w, "content required")
			return
		}
		msg, err := hub.SendMessage(r.Context(), userID, friendID, body.Content)
		if err != nil {
			apperr.Write(w, apperr.ErrInternal)
			return
		}
		w.Header().Set("Content-Type", "application/json")
		w.WriteHeader(http.StatusCreated)
		json.NewEncoder(w).Encode(msg)
	}
}

func HandleWS(hub *Hub) http.HandlerFunc {
	return func(w http.ResponseWriter, r *http.Request) {
		userID := auth.UserIDFromCtx(r.Context())
		hub.ServeWS(userID)(w, r)
	}
}
