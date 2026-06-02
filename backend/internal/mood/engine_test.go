package mood

import (
	"testing"
)

func ptr(f float64) *float64 { return &f }

func TestCalculate(t *testing.T) {
	tests := []struct {
		name  string
		input MoodInput
		want  HippoMood
	}{
		{
			name:  "no data → resting",
			input: MoodInput{},
			want:  MoodResting,
		},
		{
			name: "perfect 3 days → thriving",
			input: MoodInput{Days: []DaySummary{
				{Steps: ptr(10000), HabitTotal: 5, HabitCompleted: 5, ArticleRead: true},
				{Steps: ptr(10000), HabitTotal: 5, HabitCompleted: 5, ArticleRead: true},
				{Steps: ptr(10000), HabitTotal: 5, HabitCompleted: 5, ArticleRead: true},
			}},
			want: MoodThriving,
		},
		{
			name: "6200 steps, 3/5 habits, article read → content",
			input: MoodInput{Days: []DaySummary{
				{Steps: ptr(6200), HabitTotal: 5, HabitCompleted: 3, ArticleRead: true},
			}},
			// score: 1.0 (steps) + 0.5 (habits 60%) + 0.5 (article) = 2.0 / 3.0 = 0.667 → content
			want: MoodContent,
		},
		{
			name: "no steps, no habits → needs love",
			input: MoodInput{Days: []DaySummary{
				{Steps: ptr(100), HabitTotal: 5, HabitCompleted: 0, ArticleRead: false},
				{Steps: ptr(100), HabitTotal: 5, HabitCompleted: 0, ArticleRead: false},
				{Steps: ptr(100), HabitTotal: 5, HabitCompleted: 0, ArticleRead: false},
			}},
			want: MoodNeedsLove,
		},
		{
			name: "one great day, two poor days → resting (rolling window smooths)",
			input: MoodInput{Days: []DaySummary{
				{Steps: ptr(10000), HabitTotal: 5, HabitCompleted: 5, ArticleRead: true},
				{Steps: ptr(100)},
				{Steps: ptr(100)},
			}},
			// total: 3.0 + 0 + 0 = 3.0 / 9.0 = 0.333 → resting
			want: MoodResting,
		},
		{
			name: "day score capped at 3.0",
			input: MoodInput{Days: []DaySummary{
				{Steps: ptr(10000), HabitTotal: 1, HabitCompleted: 1, ArticleRead: true},
			}},
			// 2.0 + 1.0 + 0.5 = 3.5, capped to 3.0 / 3.0 = 1.0 → thriving
			want: MoodThriving,
		},
	}

	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			got := Calculate(tt.input)
			if got != tt.want {
				t.Errorf("Calculate() = %q, want %q", got, tt.want)
			}
		})
	}
}
