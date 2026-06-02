package auth

import (
	"context"
	"net/http"
	"strings"

	"github.com/agruenth/habbit-hippo/backend/internal/apperr"
)

type contextKey string

const UserIDKey contextKey = "userID"

func JWTMiddleware(secret string) func(http.Handler) http.Handler {
	return func(next http.Handler) http.Handler {
		return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
			header := r.Header.Get("Authorization")
			if !strings.HasPrefix(header, "Bearer ") {
				apperr.Write(w, apperr.ErrUnauthorized)
				return
			}
			claims, err := parseAccess(strings.TrimPrefix(header, "Bearer "), secret)
			if err != nil {
				apperr.Write(w, apperr.ErrUnauthorized)
				return
			}
			ctx := context.WithValue(r.Context(), UserIDKey, claims.UserID)
			next.ServeHTTP(w, r.WithContext(ctx))
		})
	}
}

func UserIDFromCtx(ctx context.Context) string {
	v, _ := ctx.Value(UserIDKey).(string)
	return v
}
