package tile

type TileDef struct {
	X                int
	Y                int
	CumulativeSteps  int64
	StreakDays       int
	ArticlesRead     int
}

// TileDefinitions are the unlock requirements for every tile.
// Home (0,0) has no requirements — always unlocked at registration.
var TileDefinitions = []TileDef{
	{X: 0, Y: 0},
	{X: 1, Y: 0, CumulativeSteps: 10_000},
	{X: -1, Y: 0, CumulativeSteps: 10_000},
	{X: 0, Y: 1, CumulativeSteps: 10_000},
	{X: 0, Y: -1, CumulativeSteps: 10_000},
	{X: 1, Y: 1, CumulativeSteps: 25_000},
	{X: -1, Y: 1, CumulativeSteps: 25_000},
	{X: 1, Y: -1, CumulativeSteps: 25_000},
	{X: -1, Y: -1, CumulativeSteps: 25_000},
	{X: 0, Y: -3, StreakDays: 7},
	{X: 0, Y: -4, StreakDays: 14},
	{X: 0, Y: 3, CumulativeSteps: 20_000},
	{X: 1, Y: 3, CumulativeSteps: 40_000},
	{X: -1, Y: 3, CumulativeSteps: 40_000},
	{X: 2, Y: 0, ArticlesRead: 5},
	{X: 2, Y: -1, ArticlesRead: 20},
}

type UserStats struct {
	CumulativeSteps int64
	CurrentStreak   int
	ArticlesRead    int
}

type Coord struct {
	X int
	Y int
}

// Zone returns the tile type name for a given coordinate.
func Zone(x, y int) string {
	if x == 0 && y == 0 {
		return "home"
	}
	if x == 2 && (y == 0 || y == -1) {
		return "library"
	}
	abs := func(n int) int {
		if n < 0 {
			return -n
		}
		return n
	}
	if y <= -3 {
		return "forest"
	}
	if y >= 3 {
		return "pond"
	}
	if abs(x)+abs(y) <= 2 {
		return "meadow"
	}
	return "locked"
}

// UnlockedCoords returns the set of (x,y) tiles that should be unlocked
// given the user's current stats. Pure function — no DB access.
func UnlockedCoords(stats UserStats) []Coord {
	var out []Coord
	for _, def := range TileDefinitions {
		if meetsRequirements(def, stats) {
			out = append(out, Coord{X: def.X, Y: def.Y})
		}
	}
	return out
}

func meetsRequirements(def TileDef, stats UserStats) bool {
	if def.CumulativeSteps > 0 && stats.CumulativeSteps < def.CumulativeSteps {
		return false
	}
	if def.StreakDays > 0 && stats.CurrentStreak < def.StreakDays {
		return false
	}
	if def.ArticlesRead > 0 && stats.ArticlesRead < def.ArticlesRead {
		return false
	}
	return true
}
