package hippo

import (
	"context"
	"database/sql"
	"errors"
	"time"

	"github.com/agruenth/habbit-hippo/backend/internal/habit"
	"github.com/agruenth/habbit-hippo/backend/internal/health"
	"github.com/agruenth/habbit-hippo/backend/internal/mood"
)

type Service struct {
	db       *sql.DB
	healthSvc *health.Service
	habitSvc  *habit.Service
}

func NewService(db *sql.DB, healthSvc *health.Service, habitSvc *habit.Service) *Service {
	return &Service{db: db, healthSvc: healthSvc, habitSvc: habitSvc}
}

type Profile struct {
	ID       string `json:"id"`
	UserID   string `json:"user_id"`
	Name     string `json:"name"`
	ColorHex string `json:"color_hex"`
}

type UpdateInput struct {
	Name     *string `json:"name"`
	ColorHex *string `json:"color_hex"`
}

type HippoState struct {
	Profile mood.HippoMood        `json:"-"`
	Hippo   Profile               `json:"hippo"`
	Mood    mood.HippoMood        `json:"mood"`
	Summary health.HealthSummary  `json:"summary"`
}

func (s *Service) Get(ctx context.Context, userID string) (HippoState, error) {
	var p Profile
	err := s.db.QueryRowContext(ctx,
		`SELECT id, user_id, name, color_hex FROM hippo_profiles WHERE user_id=?`, userID,
	).Scan(&p.ID, &p.UserID, &p.Name, &p.ColorHex)
	if errors.Is(err, sql.ErrNoRows) {
		return HippoState{}, errors.New("hippo not found")
	}
	if err != nil {
		return HippoState{}, err
	}

	// Build rolling 3-day window
	today := time.Now().Format("2006-01-02")
	dates := []string{
		time.Now().AddDate(0, 0, -2).Format("2006-01-02"),
		time.Now().AddDate(0, 0, -1).Format("2006-01-02"),
		today,
	}
	summaries, err := s.healthSvc.SummaryRange(ctx, userID, dates)
	if err != nil {
		return HippoState{}, err
	}

	days := make([]mood.DaySummary, 0, 3)
	for i, sum := range summaries {
		habitSum, _ := s.habitSvc.DailySummary(ctx, userID, dates[i])
		articleRead := s.articleReadToday(ctx, userID, dates[i])
		days = append(days, mood.DaySummary{
			Steps:          sum.Steps,
			HabitTotal:     habitSum.Total,
			HabitCompleted: habitSum.Completed,
			ArticleRead:    articleRead,
		})
	}

	currentMood := mood.Calculate(mood.MoodInput{Days: days})
	todaySummary := summaries[2]

	return HippoState{Hippo: p, Mood: currentMood, Summary: todaySummary}, nil
}

func (s *Service) Update(ctx context.Context, userID string, in UpdateInput) (Profile, error) {
	if in.Name != nil {
		_, err := s.db.ExecContext(ctx,
			`UPDATE hippo_profiles SET name=?, updated_at=unixepoch() WHERE user_id=?`,
			*in.Name, userID,
		)
		if err != nil {
			return Profile{}, err
		}
	}
	if in.ColorHex != nil {
		_, err := s.db.ExecContext(ctx,
			`UPDATE hippo_profiles SET color_hex=?, updated_at=unixepoch() WHERE user_id=?`,
			*in.ColorHex, userID,
		)
		if err != nil {
			return Profile{}, err
		}
	}
	var p Profile
	err := s.db.QueryRowContext(ctx,
		`SELECT id, user_id, name, color_hex FROM hippo_profiles WHERE user_id=?`, userID,
	).Scan(&p.ID, &p.UserID, &p.Name, &p.ColorHex)
	return p, err
}

func (s *Service) articleReadToday(ctx context.Context, userID, date string) bool {
	var count int
	s.db.QueryRowContext(ctx,
		`SELECT COUNT(*) FROM article_logs al
		 JOIN articles a ON a.id=al.article_id
		 WHERE al.user_id=? AND a.date=?`,
		userID, date,
	).Scan(&count)
	return count > 0
}
