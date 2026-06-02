package river

import (
	"testing"
	"time"
)

func TestLevel(t *testing.T) {
	tests := []struct {
		name     string
		daysAgo  float64
		wantMin  float64
		wantMax  float64
	}{
		{"just now", 0, 0.99, 1.0},
		{"5 days ago", 5, 0.49, 0.51},
		{"10 days ago", 10, 0.0, 0.01},
		{"20 days ago (dry)", 20, 0.0, 0.0},
	}
	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			last := time.Now().Add(-time.Duration(tt.daysAgo*24) * time.Hour)
			got := Level(last)
			if got < tt.wantMin || got > tt.wantMax {
				t.Errorf("Level(-%g days) = %.3f, want [%.3f, %.3f]", tt.daysAgo, got, tt.wantMin, tt.wantMax)
			}
		})
	}
}
