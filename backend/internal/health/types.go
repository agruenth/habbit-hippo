package health

const (
	MetricSteps      = "steps"
	MetricSleepHours = "sleep_hours" // v2: activate in engine once collected
	MetricWaterML    = "water_ml"    // v2
	MetricHeartRate  = "heart_rate_bpm"
)

// HealthSummary is the computed view of one day's health_entries for a user.
// Nil pointer = no data recorded for that metric that day.
type HealthSummary struct {
	Date       string   `json:"date"`
	Steps      *float64 `json:"steps,omitempty"`
	SleepHours *float64 `json:"sleep_hours,omitempty"`
	WaterML    *float64 `json:"water_ml,omitempty"`
}

type SyncEntry struct {
	Date       string  `json:"date"`
	MetricType string  `json:"metric_type"`
	Value      float64 `json:"value"`
	Unit       string  `json:"unit"`
	Source     string  `json:"source"`
}
