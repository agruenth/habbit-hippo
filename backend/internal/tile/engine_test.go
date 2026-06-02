package tile

import "testing"

func TestUnlockedCoords_HomeAlwaysUnlocked(t *testing.T) {
	coords := UnlockedCoords(UserStats{})
	for _, c := range coords {
		if c.X == 0 && c.Y == 0 {
			return
		}
	}
	t.Error("home tile (0,0) should always be unlocked")
}

func TestUnlockedCoords_StepThresholds(t *testing.T) {
	coords := UnlockedCoords(UserStats{CumulativeSteps: 10_000})
	found := map[string]bool{}
	for _, c := range coords {
		found[coord(c)] = true
	}
	for _, expected := range []string{"1,0", "-1,0", "0,1", "0,-1"} {
		if !found[expected] {
			t.Errorf("expected tile %s to be unlocked at 10k steps", expected)
		}
	}
}

func TestUnlockedCoords_StreakUnlocksForest(t *testing.T) {
	coords := UnlockedCoords(UserStats{CurrentStreak: 7})
	for _, c := range coords {
		if c.X == 0 && c.Y == -3 {
			return
		}
	}
	t.Error("forest tile (0,-3) should unlock at 7-day streak")
}

func TestUnlockedCoords_ArticlesUnlockLibrary(t *testing.T) {
	coords := UnlockedCoords(UserStats{ArticlesRead: 5})
	for _, c := range coords {
		if c.X == 2 && c.Y == 0 {
			return
		}
	}
	t.Error("library tile (2,0) should unlock at 5 articles")
}

func TestZone(t *testing.T) {
	tests := []struct{ x, y int; want string }{
		{0, 0, "home"},
		{1, 0, "meadow"},
		{0, -3, "forest"},
		{0, 3, "pond"},
		{2, 0, "library"},
	}
	for _, tt := range tests {
		got := Zone(tt.x, tt.y)
		if got != tt.want {
			t.Errorf("Zone(%d,%d) = %q, want %q", tt.x, tt.y, got, tt.want)
		}
	}
}

func coord(c Coord) string {
	return string(rune('0'+c.X+5)) + "," + string(rune('0'+c.Y+5))
}
