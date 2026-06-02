package habit

import (
	"context"
	"database/sql"
	"time"

	"github.com/google/uuid"
)

type Service struct {
	db *sql.DB
}

func NewService(db *sql.DB) *Service {
	return &Service{db: db}
}

type Definition struct {
	ID        string `json:"id"`
	Name      string `json:"name"`
	Icon      string `json:"icon"`
	Category  string `json:"category"`
	Active    bool   `json:"active"`
	SortOrder int    `json:"sort_order"`
	CreatedAt int64  `json:"created_at"`
}

type CreateInput struct {
	Name      string `json:"name"`
	Icon      string `json:"icon"`
	Category  string `json:"category"`
	SortOrder int    `json:"sort_order"`
}

type Log struct {
	ID        string  `json:"id"`
	HabitID   string  `json:"habit_id"`
	Date      string  `json:"date"`
	Completed bool    `json:"completed"`
	Note      *string `json:"note,omitempty"`
	LoggedAt  int64   `json:"logged_at"`
}

func (s *Service) List(ctx context.Context, userID string) ([]Definition, error) {
	rows, err := s.db.QueryContext(ctx,
		`SELECT id, name, icon, category, active, sort_order, created_at
		 FROM habit_definitions WHERE user_id=? AND active=1 ORDER BY sort_order, created_at`,
		userID,
	)
	if err != nil {
		return nil, err
	}
	defer rows.Close()
	var out []Definition
	for rows.Next() {
		var d Definition
		var active int
		if err := rows.Scan(&d.ID, &d.Name, &d.Icon, &d.Category, &active, &d.SortOrder, &d.CreatedAt); err != nil {
			return nil, err
		}
		d.Active = active == 1
		out = append(out, d)
	}
	return out, rows.Err()
}

func (s *Service) Create(ctx context.Context, userID string, in CreateInput) (Definition, error) {
	id := uuid.New().String()
	_, err := s.db.ExecContext(ctx,
		`INSERT INTO habit_definitions (id, user_id, name, icon, category, sort_order) VALUES (?,?,?,?,?,?)`,
		id, userID, in.Name, in.Icon, in.Category, in.SortOrder,
	)
	if err != nil {
		return Definition{}, err
	}
	return Definition{ID: id, Name: in.Name, Icon: in.Icon, Category: in.Category, Active: true, SortOrder: in.SortOrder, CreatedAt: time.Now().Unix()}, nil
}

func (s *Service) Log(ctx context.Context, userID, habitID, date string, completed bool, note *string) (Log, error) {
	id := uuid.New().String()
	_, err := s.db.ExecContext(ctx,
		`INSERT INTO habit_logs (id, habit_id, user_id, date, completed, note)
		 VALUES (?,?,?,?,?,?)
		 ON CONFLICT(habit_id, date) DO UPDATE SET completed=excluded.completed, note=excluded.note, logged_at=unixepoch()`,
		id, habitID, userID, date, completed, note,
	)
	if err != nil {
		return Log{}, err
	}
	return Log{ID: id, HabitID: habitID, Date: date, Completed: completed, Note: note, LoggedAt: time.Now().Unix()}, nil
}

type DailySummary struct {
	Date      string `json:"date"`
	Total     int    `json:"total"`
	Completed int    `json:"completed"`
}

func (s *Service) DailySummary(ctx context.Context, userID, date string) (DailySummary, error) {
	var total, completed int
	err := s.db.QueryRowContext(ctx,
		`SELECT COUNT(*), SUM(CASE WHEN hl.completed=1 THEN 1 ELSE 0 END)
		 FROM habit_definitions hd
		 LEFT JOIN habit_logs hl ON hl.habit_id=hd.id AND hl.date=?
		 WHERE hd.user_id=? AND hd.active=1`,
		date, userID,
	).Scan(&total, &completed)
	return DailySummary{Date: date, Total: total, Completed: completed}, err
}

func (s *Service) History(ctx context.Context, userID string, days int) ([]DailySummary, error) {
	rows, err := s.db.QueryContext(ctx, `
		SELECT hl.date,
		       COUNT(DISTINCT hd.id) as total,
		       SUM(CASE WHEN hl.completed=1 THEN 1 ELSE 0 END) as done
		FROM habit_definitions hd
		LEFT JOIN habit_logs hl ON hl.habit_id=hd.id AND hl.user_id=hd.user_id
		WHERE hd.user_id=? AND hd.active=1
		  AND hl.date >= date('now', ? || ' days')
		GROUP BY hl.date
		ORDER BY hl.date DESC`,
		userID, -days,
	)
	if err != nil {
		return nil, err
	}
	defer rows.Close()
	var out []DailySummary
	for rows.Next() {
		var s DailySummary
		if err := rows.Scan(&s.Date, &s.Total, &s.Completed); err != nil {
			return nil, err
		}
		out = append(out, s)
	}
	return out, rows.Err()
}
