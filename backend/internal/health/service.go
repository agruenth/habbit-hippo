package health

import (
	"context"
	"database/sql"

	"github.com/google/uuid"
)

type Service struct {
	db *sql.DB
}

func NewService(db *sql.DB) *Service {
	return &Service{db: db}
}

func (s *Service) Sync(ctx context.Context, userID string, entries []SyncEntry) error {
	tx, err := s.db.BeginTx(ctx, nil)
	if err != nil {
		return err
	}
	defer tx.Rollback()

	stmt, err := tx.PrepareContext(ctx, `
		INSERT INTO health_entries (id, user_id, date, metric_type, value, unit, source)
		VALUES (?,?,?,?,?,?,?)
		ON CONFLICT(user_id, date, metric_type) DO UPDATE SET
			value=excluded.value, source=excluded.source, recorded_at=unixepoch()
	`)
	if err != nil {
		return err
	}
	defer stmt.Close()

	for _, e := range entries {
		if _, err := stmt.ExecContext(ctx,
			uuid.New().String(), userID, e.Date, e.MetricType, e.Value, e.Unit, e.Source,
		); err != nil {
			return err
		}
	}
	return tx.Commit()
}

func (s *Service) Summary(ctx context.Context, userID, date string) (HealthSummary, error) {
	rows, err := s.db.QueryContext(ctx,
		`SELECT metric_type, value FROM health_entries WHERE user_id=? AND date=?`,
		userID, date,
	)
	if err != nil {
		return HealthSummary{}, err
	}
	defer rows.Close()

	summary := HealthSummary{Date: date}
	for rows.Next() {
		var mt string
		var val float64
		if err := rows.Scan(&mt, &val); err != nil {
			return summary, err
		}
		v := val
		switch mt {
		case MetricSteps:
			summary.Steps = &v
		case MetricSleepHours:
			summary.SleepHours = &v
		case MetricWaterML:
			summary.WaterML = &v
		}
	}
	return summary, rows.Err()
}

// SummaryRange returns summaries for the given dates (used by mood engine).
func (s *Service) SummaryRange(ctx context.Context, userID string, dates []string) ([]HealthSummary, error) {
	out := make([]HealthSummary, 0, len(dates))
	for _, d := range dates {
		sum, err := s.Summary(ctx, userID, d)
		if err != nil {
			return nil, err
		}
		out = append(out, sum)
	}
	return out, nil
}
