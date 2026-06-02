package auth

import (
	"encoding/json"
	"net/http"
	"strings"

	"github.com/agruenth/habbit-hippo/backend/internal/apperr"
)

func HandleRegister(svc *Service) http.HandlerFunc {
	type req struct {
		Email    string `json:"email"`
		Username string `json:"username"`
		Password string `json:"password"`
	}
	return func(w http.ResponseWriter, r *http.Request) {
		var body req
		if err := json.NewDecoder(r.Body).Decode(&body); err != nil {
			apperr.BadRequest(w, "invalid JSON")
			return
		}
		body.Email = strings.TrimSpace(strings.ToLower(body.Email))
		body.Username = strings.TrimSpace(body.Username)
		if body.Email == "" || body.Username == "" || len(body.Password) < 8 {
			apperr.BadRequest(w, "email, username, and password (min 8 chars) required")
			return
		}
		pair, err := svc.Register(r.Context(), RegisterInput{
			Email: body.Email, Username: body.Username, Password: body.Password,
		})
		if err != nil {
			if strings.Contains(err.Error(), "UNIQUE") {
				apperr.Write(w, apperr.ErrConflict)
			} else {
				apperr.Write(w, apperr.ErrInternal)
			}
			return
		}
		w.Header().Set("Content-Type", "application/json")
		w.WriteHeader(http.StatusCreated)
		json.NewEncoder(w).Encode(pair)
	}
}

func HandleLogin(svc *Service) http.HandlerFunc {
	type req struct {
		Email    string `json:"email"`
		Password string `json:"password"`
	}
	return func(w http.ResponseWriter, r *http.Request) {
		var body req
		if err := json.NewDecoder(r.Body).Decode(&body); err != nil {
			apperr.BadRequest(w, "invalid JSON")
			return
		}
		pair, err := svc.Login(r.Context(), LoginInput{Email: body.Email, Password: body.Password})
		if err != nil {
			apperr.Write(w, apperr.ErrUnauthorized)
			return
		}
		w.Header().Set("Content-Type", "application/json")
		json.NewEncoder(w).Encode(pair)
	}
}

func HandleRefresh(svc *Service) http.HandlerFunc {
	type req struct {
		RefreshToken string `json:"refresh_token"`
	}
	return func(w http.ResponseWriter, r *http.Request) {
		var body req
		if err := json.NewDecoder(r.Body).Decode(&body); err != nil || body.RefreshToken == "" {
			apperr.BadRequest(w, "refresh_token required")
			return
		}
		pair, err := svc.Refresh(r.Context(), body.RefreshToken)
		if err != nil {
			apperr.Write(w, apperr.ErrUnauthorized)
			return
		}
		w.Header().Set("Content-Type", "application/json")
		json.NewEncoder(w).Encode(pair)
	}
}
