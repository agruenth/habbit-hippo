package mood

type HippoMood string

const (
	MoodThriving  HippoMood = "thriving"
	MoodContent   HippoMood = "content"
	MoodResting   HippoMood = "resting"
	MoodNeedsLove HippoMood = "needs_love"
)

// DaySummary is the input for a single day's data.
// All optional fields are nil when no data exists for that metric.
type DaySummary struct {
	Steps          *float64
	HabitTotal     int
	HabitCompleted int
	ArticleRead    bool
	// Extensibility: add SleepHours *float64, WaterML *float64, etc.
}

// MoodInput holds 1–3 days (oldest first) for the rolling window.
type MoodInput struct {
	Days []DaySummary
}

const maxDayScore = 3.0

func scoreDay(d DaySummary) float64 {
	score := 0.0

	if d.Steps != nil {
		switch {
		case *d.Steps >= 8000:
			score += 2.0
		case *d.Steps >= 5000:
			score += 1.0
		}
	}

	if d.HabitTotal > 0 {
		rate := float64(d.HabitCompleted) / float64(d.HabitTotal)
		switch {
		case rate >= 0.8:
			score += 1.0
		case rate >= 0.5:
			score += 0.5
		}
	}

	if d.ArticleRead {
		score += 0.5
	}

	if score > maxDayScore {
		score = maxDayScore
	}
	return score
}

// Calculate derives the hippo mood from a rolling window of up to 3 days.
// This is a pure function — no DB, no HTTP, fully unit-testable.
func Calculate(input MoodInput) HippoMood {
	if len(input.Days) == 0 {
		return MoodResting
	}

	windowMax := maxDayScore * float64(len(input.Days))
	total := 0.0
	for _, d := range input.Days {
		total += scoreDay(d)
	}
	ratio := total / windowMax

	switch {
	case ratio >= 0.85:
		return MoodThriving
	case ratio >= 0.50:
		return MoodContent
	case ratio >= 0.20:
		return MoodResting
	default:
		return MoodNeedsLove
	}
}
