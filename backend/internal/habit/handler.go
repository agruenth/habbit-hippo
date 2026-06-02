package habit

import (
	"encoding/json"
	"net/http"
	"strconv"
	"time"

	"github.com/go-chi/chi/v5"
	"github.com/agruenth/habbit-hippo/backend/internal/apperr"
	"github.com/agruenth/habbit-hippo/backend/internal/auth"
)

func HandleList(svc *Service) http.HandlerFunc {
	return func(w http.ResponseWriter, r *http.Request) {
		userID := auth.UserIDFromCtx(r.Context())
		habits, err := svc.List(r.Context(), userID)
		if err != nil {
			apperr.Write(w, apperr.ErrInternal)
			return
		}
		w.Header().Set("Content-Type", "application/json")
		json.NewEncoder(w).Encode(habits)
	}
}

func HandleCreate(svc *Service) http.HandlerFunc {
	return func(w http.ResponseWriter, r *http.Request) {
		userID := auth.UserIDFromCtx(r.Context())
		var in CreateInput
		if err := json.NewDecoder(r.Body).Decode(&in); err != nil || in.Name == "" {
			apperr.BadRequest(w, "name required")
			return
		}
		if in.Icon == "" {
			in.Icon = "✅"
		}
		d, err := svc.Create(r.Context(), userID, in)
		if err != nil {
			apperr.Write(w, apperr.ErrInternal)
			return
		}
		w.Header().Set("Content-Type", "application/json")
		w.WriteHeader(http.StatusCreated)
		json.NewEncoder(w).Encode(d)
	}
}

func HandleLog(svc *Service) http.HandlerFunc {
	type req struct {
		Date      string  `json:"date"`
		Completed bool    `json:"completed"`
		Note      *string `json:"note"`
	}
	return func(w http.ResponseWriter, r *http.Request) {
		userID := auth.UserIDFromCtx(r.Context())
		habitID := chi.URLParam(r, "id")
		var body req
		if err := json.NewDecoder(r.Body).Decode(&body); err != nil {
			apperr.BadRequest(w, "invalid JSON")
			return
		}
		if body.Date == "" {
			body.Date = time.Now().Format("2006-01-02")
		}
		l, err := svc.Log(r.Context(), userID, habitID, body.Date, body.Completed, body.Note)
		if err != nil {
			apperr.Write(w, apperr.ErrInternal)
			return
		}
		w.Header().Set("Content-Type", "application/json")
		json.NewEncoder(w).Encode(l)
	}
}

func HandleHistory(svc *Service) http.HandlerFunc {
	return func(w http.ResponseWriter, r *http.Request) {
		userID := auth.UserIDFromCtx(r.Context())
		days := 30
		if d := r.URL.Query().Get("days"); d != "" {
			if n, err := strconv.Atoi(d); err == nil && n > 0 {
				days = n
			}
		}
		history, err := svc.History(r.Context(), userID, days)
		if err != nil {
			apperr.Write(w, apperr.ErrInternal)
			return
		}
		w.Header().Set("Content-Type", "application/json")
		json.NewEncoder(w).Encode(history)
	}
}
