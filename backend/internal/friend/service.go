package friend

import (
	"context"
	"database/sql"
	"errors"
	"time"

	"github.com/google/uuid"
)

type Service struct {
	db *sql.DB
}

func NewService(db *sql.DB) *Service {
	return &Service{db: db}
}

type Friend struct {
	FriendshipID string `json:"friendship_id"`
	UserID       string `json:"user_id"`
	Username     string `json:"username"`
	HippoName    string `json:"hippo_name"`
	HippoColor   string `json:"hippo_color"`
	RiverLevel   float64 `json:"river_level"`
	LastMessageAt *int64  `json:"last_message_at,omitempty"`
}

func (s *Service) List(ctx context.Context, userID string) ([]Friend, error) {
	rows, err := s.db.QueryContext(ctx, `
		SELECT f.id,
		       CASE WHEN f.requester_id=? THEN f.addressee_id ELSE f.requester_id END as friend_id,
		       u.username, hp.name, hp.color_hex,
		       (SELECT MAX(sent_at) FROM messages
		        WHERE (sender_id=? AND recipient_id=friend_id)
		           OR (sender_id=friend_id AND recipient_id=?)) as last_msg
		FROM friendships f
		JOIN users u ON u.id = CASE WHEN f.requester_id=? THEN f.addressee_id ELSE f.requester_id END
		JOIN hippo_profiles hp ON hp.user_id = u.id
		WHERE (f.requester_id=? OR f.addressee_id=?) AND f.status='accepted'`,
		userID, userID, userID, userID, userID, userID,
	)
	if err != nil {
		return nil, err
	}
	defer rows.Close()

	var out []Friend
	for rows.Next() {
		var fr Friend
		var lastMsg sql.NullInt64
		if err := rows.Scan(&fr.FriendshipID, &fr.UserID, &fr.Username, &fr.HippoName, &fr.HippoColor, &lastMsg); err != nil {
			return nil, err
		}
		if lastMsg.Valid {
			t := lastMsg.Int64
			fr.LastMessageAt = &t
			last := time.Unix(t, 0)
			fr.RiverLevel = riverLevel(last)
		}
		out = append(out, fr)
	}
	return out, rows.Err()
}

func (s *Service) SendRequest(ctx context.Context, requesterID, addresseeUsername string) error {
	var addresseeID string
	err := s.db.QueryRowContext(ctx,
		`SELECT id FROM users WHERE username=?`, addresseeUsername,
	).Scan(&addresseeID)
	if errors.Is(err, sql.ErrNoRows) {
		return errors.New("user not found")
	}
	if err != nil {
		return err
	}
	_, err = s.db.ExecContext(ctx,
		`INSERT INTO friendships (id, requester_id, addressee_id) VALUES (?,?,?)`,
		uuid.New().String(), requesterID, addresseeID,
	)
	return err
}

func (s *Service) Respond(ctx context.Context, userID, friendshipID, action string) error {
	status := "accepted"
	if action == "decline" {
		status = "blocked"
	}
	res, err := s.db.ExecContext(ctx,
		`UPDATE friendships SET status=? WHERE id=? AND addressee_id=? AND status='pending'`,
		status, friendshipID, userID,
	)
	if err != nil {
		return err
	}
	n, _ := res.RowsAffected()
	if n == 0 {
		return errors.New("friendship not found")
	}
	return nil
}

func (s *Service) Remove(ctx context.Context, userID, friendshipID string) error {
	_, err := s.db.ExecContext(ctx,
		`DELETE FROM friendships WHERE id=? AND (requester_id=? OR addressee_id=?)`,
		friendshipID, userID, userID,
	)
	return err
}

func (s *Service) PendingRequests(ctx context.Context, userID string) ([]map[string]string, error) {
	rows, err := s.db.QueryContext(ctx, `
		SELECT f.id, u.username
		FROM friendships f
		JOIN users u ON u.id=f.requester_id
		WHERE f.addressee_id=? AND f.status='pending'`,
		userID,
	)
	if err != nil {
		return nil, err
	}
	defer rows.Close()
	var out []map[string]string
	for rows.Next() {
		var id, username string
		if err := rows.Scan(&id, &username); err != nil {
			return nil, err
		}
		out = append(out, map[string]string{"friendship_id": id, "username": username})
	}
	return out, rows.Err()
}

func riverLevel(lastMsg time.Time) float64 {
	days := time.Since(lastMsg).Hours() / 24
	level := 1.0 - days/10.0
	if level < 0 {
		return 0
	}
	return level
}
