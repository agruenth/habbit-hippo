package hippo

import (
	"encoding/json"
	"net/http"

	"github.com/agruenth/habbit-hippo/backend/internal/apperr"
	"github.com/agruenth/habbit-hippo/backend/internal/auth"
)

func HandleGet(svc *Service) http.HandlerFunc {
	return func(w http.ResponseWriter, r *http.Request) {
		userID := auth.UserIDFromCtx(r.Context())
		state, err := svc.Get(r.Context(), userID)
		if err != nil {
			apperr.Write(w, apperr.ErrInternal)
			return
		}
		w.Header().Set("Content-Type", "application/json")
		json.NewEncoder(w).Encode(state)
	}
}

func HandleUpdate(svc *Service) http.HandlerFunc {
	return func(w http.ResponseWriter, r *http.Request) {
		userID := auth.UserIDFromCtx(r.Context())
		var in UpdateInput
		if err := json.NewDecoder(r.Body).Decode(&in); err != nil {
			apperr.BadRequest(w, "invalid JSON")
			return
		}
		p, err := svc.Update(r.Context(), userID, in)
		if err != nil {
			apperr.Write(w, apperr.ErrInternal)
			return
		}
		w.Header().Set("Content-Type", "application/json")
		json.NewEncoder(w).Encode(p)
	}
}
