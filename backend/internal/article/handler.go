package article

import (
	"encoding/json"
	"net/http"

	"github.com/agruenth/habbit-hippo/backend/internal/apperr"
	"github.com/agruenth/habbit-hippo/backend/internal/auth"
)

func HandleToday(svc *Service) http.HandlerFunc {
	return func(w http.ResponseWriter, r *http.Request) {
		a, err := svc.Today(r.Context())
		if err != nil {
			apperr.Write(w, apperr.ErrNotFound)
			return
		}
		w.Header().Set("Content-Type", "application/json")
		json.NewEncoder(w).Encode(a)
	}
}

func HandleLog(svc *Service) http.HandlerFunc {
	type req struct {
		ArticleID     string `json:"article_id"`
		Comprehension string `json:"comprehension"`
	}
	return func(w http.ResponseWriter, r *http.Request) {
		userID := auth.UserIDFromCtx(r.Context())
		var body req
		if err := json.NewDecoder(r.Body).Decode(&body); err != nil || body.ArticleID == "" {
			apperr.BadRequest(w, "article_id required")
			return
		}
		if body.Comprehension == "" {
			body.Comprehension = "completed"
		}
		l, err := svc.Log(r.Context(), userID, body.ArticleID, body.Comprehension)
		if err != nil {
			apperr.Write(w, apperr.ErrInternal)
			return
		}
		w.Header().Set("Content-Type", "application/json")
		w.WriteHeader(http.StatusCreated)
		json.NewEncoder(w).Encode(l)
	}
}

func HandleStats(svc *Service) http.HandlerFunc {
	return func(w http.ResponseWriter, r *http.Request) {
		userID := auth.UserIDFromCtx(r.Context())
		stats, err := svc.UserStats(r.Context(), userID)
		if err != nil {
			apperr.Write(w, apperr.ErrInternal)
			return
		}
		w.Header().Set("Content-Type", "application/json")
		json.NewEncoder(w).Encode(stats)
	}
}
