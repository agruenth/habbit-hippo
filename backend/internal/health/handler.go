package health

import (
	"encoding/json"
	"net/http"
	"time"

	"github.com/agruenth/habbit-hippo/backend/internal/apperr"
	"github.com/agruenth/habbit-hippo/backend/internal/auth"
)

func HandleSync(svc *Service) http.HandlerFunc {
	type req struct {
		Entries []SyncEntry `json:"entries"`
	}
	return func(w http.ResponseWriter, r *http.Request) {
		userID := auth.UserIDFromCtx(r.Context())
		var body req
		if err := json.NewDecoder(r.Body).Decode(&body); err != nil {
			apperr.BadRequest(w, "invalid JSON")
			return
		}
		if len(body.Entries) == 0 {
			apperr.BadRequest(w, "entries required")
			return
		}
		if err := svc.Sync(r.Context(), userID, body.Entries); err != nil {
			apperr.Write(w, apperr.ErrInternal)
			return
		}
		w.WriteHeader(http.StatusNoContent)
	}
}

func HandleSummary(svc *Service) http.HandlerFunc {
	return func(w http.ResponseWriter, r *http.Request) {
		userID := auth.UserIDFromCtx(r.Context())
		date := r.URL.Query().Get("date")
		if date == "" {
			date = time.Now().Format("2006-01-02")
		}
		summary, err := svc.Summary(r.Context(), userID, date)
		if err != nil {
			apperr.Write(w, apperr.ErrInternal)
			return
		}
		w.Header().Set("Content-Type", "application/json")
		json.NewEncoder(w).Encode(summary)
	}
}
