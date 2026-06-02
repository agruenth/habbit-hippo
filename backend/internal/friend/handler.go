package friend

import (
	"encoding/json"
	"net/http"

	"github.com/go-chi/chi/v5"
	"github.com/agruenth/habbit-hippo/backend/internal/apperr"
	"github.com/agruenth/habbit-hippo/backend/internal/auth"
)

func HandleList(svc *Service) http.HandlerFunc {
	return func(w http.ResponseWriter, r *http.Request) {
		userID := auth.UserIDFromCtx(r.Context())
		friends, err := svc.List(r.Context(), userID)
		if err != nil {
			apperr.Write(w, apperr.ErrInternal)
			return
		}
		w.Header().Set("Content-Type", "application/json")
		json.NewEncoder(w).Encode(friends)
	}
}

func HandleRequest(svc *Service) http.HandlerFunc {
	type req struct {
		Username string `json:"username"`
	}
	return func(w http.ResponseWriter, r *http.Request) {
		userID := auth.UserIDFromCtx(r.Context())
		var body req
		if err := json.NewDecoder(r.Body).Decode(&body); err != nil || body.Username == "" {
			apperr.BadRequest(w, "username required")
			return
		}
		if err := svc.SendRequest(r.Context(), userID, body.Username); err != nil {
			apperr.Write(w, apperr.ErrInternal)
			return
		}
		w.WriteHeader(http.StatusNoContent)
	}
}

func HandleRespond(svc *Service) http.HandlerFunc {
	type req struct {
		Action string `json:"action"` // "accept" | "decline"
	}
	return func(w http.ResponseWriter, r *http.Request) {
		userID := auth.UserIDFromCtx(r.Context())
		id := chi.URLParam(r, "id")
		var body req
		if err := json.NewDecoder(r.Body).Decode(&body); err != nil {
			apperr.BadRequest(w, "invalid JSON")
			return
		}
		if err := svc.Respond(r.Context(), userID, id, body.Action); err != nil {
			apperr.Write(w, apperr.ErrNotFound)
			return
		}
		w.WriteHeader(http.StatusNoContent)
	}
}

func HandleRemove(svc *Service) http.HandlerFunc {
	return func(w http.ResponseWriter, r *http.Request) {
		userID := auth.UserIDFromCtx(r.Context())
		id := chi.URLParam(r, "id")
		if err := svc.Remove(r.Context(), userID, id); err != nil {
			apperr.Write(w, apperr.ErrInternal)
			return
		}
		w.WriteHeader(http.StatusNoContent)
	}
}

func HandlePending(svc *Service) http.HandlerFunc {
	return func(w http.ResponseWriter, r *http.Request) {
		userID := auth.UserIDFromCtx(r.Context())
		pending, err := svc.PendingRequests(r.Context(), userID)
		if err != nil {
			apperr.Write(w, apperr.ErrInternal)
			return
		}
		w.Header().Set("Content-Type", "application/json")
		json.NewEncoder(w).Encode(pending)
	}
}
