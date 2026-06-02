package article

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

type Article struct {
	ID              string `json:"id"`
	Date            string `json:"date"`
	Title           string `json:"title"`
	Topic           string `json:"topic"`
	SourceName      string `json:"source_name"`
	SourceURL       string `json:"source_url"`
	Summary         string `json:"summary"`
	ReadingTimeMins int    `json:"reading_time_mins"`
}

type ArticleLog struct {
	ID            string `json:"id"`
	ArticleID     string `json:"article_id"`
	ReadAt        int64  `json:"read_at"`
	Comprehension string `json:"comprehension"`
}

type Stats struct {
	TotalRead    int `json:"total_read"`
	CurrentStreak int `json:"current_streak"`
	BestStreak   int `json:"best_streak"`
}

func (s *Service) Today(ctx context.Context) (Article, error) {
	date := time.Now().Format("2006-01-02")
	var a Article
	err := s.db.QueryRowContext(ctx,
		`SELECT id, date, title, topic, source_name, source_url, summary, reading_time_mins
		 FROM articles WHERE date=?`, date,
	).Scan(&a.ID, &a.Date, &a.Title, &a.Topic, &a.SourceName, &a.SourceURL, &a.Summary, &a.ReadingTimeMins)
	if errors.Is(err, sql.ErrNoRows) {
		return Article{}, errors.New("no article for today")
	}
	return a, err
}

func (s *Service) Log(ctx context.Context, userID, articleID, comprehension string) (ArticleLog, error) {
	id := uuid.New().String()
	_, err := s.db.ExecContext(ctx,
		`INSERT INTO article_logs (id, user_id, article_id, comprehension)
		 VALUES (?,?,?,?)
		 ON CONFLICT(user_id, article_id) DO UPDATE SET comprehension=excluded.comprehension, read_at=unixepoch()`,
		id, userID, articleID, comprehension,
	)
	if err != nil {
		return ArticleLog{}, err
	}
	return ArticleLog{ID: id, ArticleID: articleID, ReadAt: time.Now().Unix(), Comprehension: comprehension}, nil
}

func (s *Service) UserStats(ctx context.Context, userID string) (Stats, error) {
	var total int
	s.db.QueryRowContext(ctx,
		`SELECT COUNT(*) FROM article_logs WHERE user_id=?`, userID,
	).Scan(&total)
	return Stats{TotalRead: total, CurrentStreak: 0, BestStreak: 0}, nil
}
