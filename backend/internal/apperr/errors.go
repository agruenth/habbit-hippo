package apperr

import (
	"encoding/json"
	"net/http"
)

type APIError struct {
	Code    int    `json:"-"`
	Message string `json:"error"`
}

func (e *APIError) Error() string { return e.Message }

var (
	ErrUnauthorized   = &APIError{Code: http.StatusUnauthorized, Message: "unauthorized"}
	ErrForbidden      = &APIError{Code: http.StatusForbidden, Message: "forbidden"}
	ErrNotFound       = &APIError{Code: http.StatusNotFound, Message: "not found"}
	ErrBadRequest     = &APIError{Code: http.StatusBadRequest, Message: "bad request"}
	ErrConflict       = &APIError{Code: http.StatusConflict, Message: "conflict"}
	ErrInternal       = &APIError{Code: http.StatusInternalServerError, Message: "internal server error"}
)

func Write(w http.ResponseWriter, err *APIError) {
	w.Header().Set("Content-Type", "application/json")
	w.WriteHeader(err.Code)
	json.NewEncoder(w).Encode(err)
}

func BadRequest(w http.ResponseWriter, msg string) {
	Write(w, &APIError{Code: http.StatusBadRequest, Message: msg})
}
