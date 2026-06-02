package auth

import (
	"context"
	"database/sql"
	"errors"
	"fmt"
	"time"

	"github.com/google/uuid"
	"golang.org/x/crypto/bcrypt"
)

type Service struct {
	db     *sql.DB
	secret string
}

func NewService(db *sql.DB, secret string) *Service {
	return &Service{db: db, secret: secret}
}

type RegisterInput struct {
	Email    string
	Username string
	Password string
}

type TokenPair struct {
	AccessToken  string `json:"access_token"`
	RefreshToken string `json:"refresh_token"`
}

func (s *Service) Register(ctx context.Context, in RegisterInput) (TokenPair, error) {
	hash, err := bcrypt.GenerateFromPassword([]byte(in.Password), bcrypt.DefaultCost)
	if err != nil {
		return TokenPair{}, err
	}
	userID := uuid.New().String()
	_, err = s.db.ExecContext(ctx,
		`INSERT INTO users (id, email, username, password_hash) VALUES (?,?,?,?)`,
		userID, in.Email, in.Username, string(hash),
	)
	if err != nil {
		return TokenPair{}, fmt.Errorf("create user: %w", err)
	}

	hippoID := uuid.New().String()
	_, err = s.db.ExecContext(ctx,
		`INSERT INTO hippo_profiles (id, user_id) VALUES (?,?)`,
		hippoID, userID,
	)
	if err != nil {
		return TokenPair{}, fmt.Errorf("create hippo: %w", err)
	}

	// Unlock home tile (0,0)
	_, _ = s.db.ExecContext(ctx,
		`INSERT OR IGNORE INTO tiles (id, user_id, x, y, unlocked_at) VALUES (?,?,0,0,unixepoch())`,
		uuid.New().String(), userID,
	)

	return s.issueTokens(ctx, userID)
}

type LoginInput struct {
	Email    string
	Password string
}

func (s *Service) Login(ctx context.Context, in LoginInput) (TokenPair, error) {
	var userID, hash string
	err := s.db.QueryRowContext(ctx,
		`SELECT id, password_hash FROM users WHERE email = ?`, in.Email,
	).Scan(&userID, &hash)
	if errors.Is(err, sql.ErrNoRows) {
		return TokenPair{}, fmt.Errorf("invalid credentials")
	}
	if err != nil {
		return TokenPair{}, err
	}
	if err := bcrypt.CompareHashAndPassword([]byte(hash), []byte(in.Password)); err != nil {
		return TokenPair{}, fmt.Errorf("invalid credentials")
	}
	return s.issueTokens(ctx, userID)
}

func (s *Service) Refresh(ctx context.Context, plain string) (TokenPair, error) {
	hashed := hashToken(plain)
	var tokenID, userID string
	var expiresAt int64
	var revoked int
	err := s.db.QueryRowContext(ctx,
		`SELECT id, user_id, expires_at, revoked FROM refresh_tokens WHERE token_hash = ?`, hashed,
	).Scan(&tokenID, &userID, &expiresAt, &revoked)
	if errors.Is(err, sql.ErrNoRows) || revoked == 1 {
		return TokenPair{}, fmt.Errorf("invalid refresh token")
	}
	if err != nil {
		return TokenPair{}, err
	}
	if time.Now().Unix() > expiresAt {
		return TokenPair{}, fmt.Errorf("refresh token expired")
	}
	// Rotate: revoke old, issue new
	_, _ = s.db.ExecContext(ctx, `UPDATE refresh_tokens SET revoked=1 WHERE id=?`, tokenID)
	return s.issueTokens(ctx, userID)
}

func (s *Service) issueTokens(ctx context.Context, userID string) (TokenPair, error) {
	access, err := signAccess(userID, s.secret)
	if err != nil {
		return TokenPair{}, err
	}
	plain, hashed, err := newRefreshToken()
	if err != nil {
		return TokenPair{}, err
	}
	_, err = s.db.ExecContext(ctx,
		`INSERT INTO refresh_tokens (id, user_id, token_hash, expires_at) VALUES (?,?,?,?)`,
		uuid.New().String(), userID, hashed, time.Now().Add(refreshTTL).Unix(),
	)
	if err != nil {
		return TokenPair{}, err
	}
	return TokenPair{AccessToken: access, RefreshToken: plain}, nil
}
