package river

import "time"

const dryAfterDays = 10.0

// Level returns a water level in [0.0, 1.0].
// The river dries completely after 10 days of silence.
// Pure function — no DB, no HTTP.
func Level(lastMessageAt time.Time) float64 {
	days := time.Since(lastMessageAt).Hours() / 24
	level := 1.0 - days/dryAfterDays
	if level < 0 {
		return 0
	}
	if level > 1 {
		return 1
	}
	return level
}
