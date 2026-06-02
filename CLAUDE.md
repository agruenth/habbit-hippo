# Habbit Hippo — Project Context for Claude Code

## What this project is

A Flutter + Go companion app. A hippo's mood reflects your physical and digital wellbeing.
- **Physical**: steps + custom habits → hippo mood → tile unlocks on a hex world map
- **Digital**: chat frequency with friends → river/pond water level (dries after 10 days of silence)
- **Reading**: Article of the Day (10 min/day) → mood bonus + library tile unlocks
- Full plan and design rationale: see `mockups/index.html` for interactive screen mockups

## Repo layout

```
habbit-hippo/
├── app/          Flutter application (not yet scaffolded)
├── backend/      Go server         (not yet scaffolded)
├── mockups/      HTML mockups — open index.html in a browser to see all screens
└── CLAUDE.md     ← you are here
```

## Implementation order (follow this exactly)

### Phase 1 — Foundation
1. `backend/`: `go mod init`, directory structure, `docker-compose.yml`
2. `backend/db/migrations/001_initial.sql` — full schema (see below)
3. Auth: register / login / refresh (JWT + bcrypt), JWT middleware

### Phase 2 — Physical Wellbeing
4. `POST /health/sync` (batch upsert), `GET /health/summary`
5. `GET|POST /habits`, `POST /habits/:id/log`, `GET /habits/history`
6. Mood engine (`internal/mood/engine.go`) — pure function, table-driven tests
7. `GET /hippo`, `PUT /hippo`

### Phase 3 — World + Articles
8. Tile unlock engine (`internal/tile/engine.go`) — pure function, tests
9. `GET /world`, `POST /world/visit/:x/:y`
10. `GET /article/today`, `POST /article/log`, `GET /article/stats`

### Phase 4 — Digital Wellbeing (Social)
11. Friends CRUD (`GET /friends`, `POST /friends/request`, `POST /friends/respond`, `DELETE /friends/:id`)
12. Chat HTTP (`GET /chat/:id`, `POST /chat/:id`)
13. WebSocket hub (`internal/chat/hub.go`), `GET /ws`
14. River engine (`internal/river/engine.go`) — pure function, tests

### Phase 5 — Flutter Core
15. `flutter create app`, pubspec.yaml with all packages
16. Dio client + JWT interceptor (refresh on 401), `flutter_secure_storage`
17. `go_router` + 4-tab shell, login / register screens

### Phase 6 — Flutter Features
18. Health → Drift local cache → sync provider
19. Hippo tab: `hippoProvider`, Rive widget (stub), stats row
20. Habits tab: `habitsProvider`, wellbeing dashboard, habit list + article card
21. World tab: `worldProvider`, hex tile grid (`InteractiveViewer` + `ClipPath`)
22. Article screen: article hero, comprehension check, reward progress bars
23. Friends tab + Chat screen: `wsProvider`, `chatProvider`, pond view

### Phase 7 — Polish
24. `workmanager` background health sync
25. Streak calendar widget (habit history)
26. Tile unlock animation + animal encounter modal

---

## Database schema (SQLite)

```sql
CREATE TABLE users (
    id TEXT PRIMARY KEY, email TEXT NOT NULL UNIQUE,
    username TEXT NOT NULL UNIQUE, password_hash TEXT NOT NULL,
    created_at INTEGER NOT NULL DEFAULT (unixepoch()),
    updated_at INTEGER NOT NULL DEFAULT (unixepoch())
);
CREATE TABLE refresh_tokens (
    id TEXT PRIMARY KEY, user_id TEXT NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    token_hash TEXT NOT NULL UNIQUE, expires_at INTEGER NOT NULL, revoked INTEGER NOT NULL DEFAULT 0
);
CREATE TABLE hippo_profiles (
    id TEXT PRIMARY KEY, user_id TEXT NOT NULL UNIQUE REFERENCES users(id) ON DELETE CASCADE,
    name TEXT NOT NULL DEFAULT 'Hippo', color_hex TEXT NOT NULL DEFAULT '#A8D8EA',
    created_at INTEGER NOT NULL DEFAULT (unixepoch()), updated_at INTEGER NOT NULL DEFAULT (unixepoch())
);
CREATE TABLE health_entries (
    id TEXT PRIMARY KEY, user_id TEXT NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    date TEXT NOT NULL, metric_type TEXT NOT NULL,
    value REAL NOT NULL, unit TEXT NOT NULL, source TEXT NOT NULL,
    recorded_at INTEGER NOT NULL DEFAULT (unixepoch()),
    UNIQUE(user_id, date, metric_type)
);
CREATE INDEX idx_health_user_date ON health_entries(user_id, date);
CREATE TABLE habit_definitions (
    id TEXT PRIMARY KEY, user_id TEXT NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    name TEXT NOT NULL, icon TEXT NOT NULL,
    category TEXT NOT NULL,   -- 'physical','digital','mindfulness','social'
    active INTEGER NOT NULL DEFAULT 1, sort_order INTEGER NOT NULL DEFAULT 0,
    created_at INTEGER NOT NULL DEFAULT (unixepoch())
);
CREATE TABLE habit_logs (
    id TEXT PRIMARY KEY, habit_id TEXT NOT NULL REFERENCES habit_definitions(id) ON DELETE CASCADE,
    user_id TEXT NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    date TEXT NOT NULL, completed INTEGER NOT NULL DEFAULT 0, note TEXT,
    logged_at INTEGER NOT NULL DEFAULT (unixepoch()), UNIQUE(habit_id, date)
);
CREATE INDEX idx_habit_logs_user_date ON habit_logs(user_id, date);
CREATE TABLE articles (
    id TEXT PRIMARY KEY, date TEXT NOT NULL UNIQUE, title TEXT NOT NULL,
    topic TEXT NOT NULL, source_name TEXT NOT NULL, source_url TEXT NOT NULL,
    summary TEXT NOT NULL, reading_time_mins INTEGER NOT NULL DEFAULT 10,
    published_at INTEGER NOT NULL DEFAULT (unixepoch())
);
CREATE TABLE article_logs (
    id TEXT PRIMARY KEY, user_id TEXT NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    article_id TEXT NOT NULL REFERENCES articles(id) ON DELETE CASCADE,
    read_at INTEGER NOT NULL DEFAULT (unixepoch()),
    comprehension TEXT NOT NULL DEFAULT 'completed',  -- 'confused','pondering','eureka'
    UNIQUE(user_id, article_id)
);
CREATE INDEX idx_article_logs_user ON article_logs(user_id, read_at DESC);
CREATE TABLE tiles (
    id TEXT PRIMARY KEY, user_id TEXT NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    x INTEGER NOT NULL, y INTEGER NOT NULL, unlocked_at INTEGER,
    UNIQUE(user_id, x, y)
);
CREATE TABLE animal_encounters (
    id TEXT PRIMARY KEY, user_id TEXT NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    tile_x INTEGER NOT NULL, tile_y INTEGER NOT NULL, animal_type TEXT NOT NULL,
    first_met_at INTEGER NOT NULL, last_seen_at INTEGER NOT NULL,
    UNIQUE(user_id, tile_x, tile_y, animal_type)
);
CREATE TABLE friendships (
    id TEXT PRIMARY KEY,
    requester_id TEXT NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    addressee_id TEXT NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    status TEXT NOT NULL DEFAULT 'pending',  -- 'pending','accepted','blocked'
    created_at INTEGER NOT NULL DEFAULT (unixepoch()),
    UNIQUE(requester_id, addressee_id)
);
CREATE TABLE messages (
    id TEXT PRIMARY KEY,
    sender_id TEXT NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    recipient_id TEXT NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    content TEXT NOT NULL, sent_at INTEGER NOT NULL DEFAULT (unixepoch()), read_at INTEGER
);
CREATE INDEX idx_messages_conv ON messages(MIN(sender_id,recipient_id), MAX(sender_id,recipient_id), sent_at DESC);
```

---

## Key Go packages

```
github.com/go-chi/chi/v5
modernc.org/sqlite
github.com/golang-jwt/jwt/v5
golang.org/x/crypto
github.com/google/uuid
github.com/gorilla/websocket
```

## Key Flutter packages

```yaml
flutter_riverpod: ^2.5.0
go_router: ^14.0.0
health: ^12.0.0
drift: ^2.18.0
drift_flutter: ^0.2.0
dio: ^5.4.0
flutter_secure_storage: ^9.0.0
rive: ^0.13.0
workmanager: ^0.5.2
web_socket_channel: ^2.4.0
intl: ^0.19.0
```

---

## Three pure-function engines (never store their output — always recompute)

### Mood engine (`internal/mood/engine.go`)
- Input: 3-day `[]DaySummary{Steps *float64, HabitTotal, HabitCompleted int, ArticleRead bool}`
- Per-day score: steps≥8000→+2, steps≥5000→+1, habit_rate≥0.8→+1, habit_rate≥0.5→+0.5, article_read→+0.5
- Cap day score at 3.0; 3-day window max = 9
- `ratio = total/9`; thresholds: ≥0.85 Thriving · ≥0.50 Content · ≥0.20 Resting · else NeedsLove

### Tile unlock engine (`internal/tile/engine.go`)
- Input: `UserStats{CumulativeSteps int64, CurrentStreak int, ArticlesRead int}`
- Returns set of (x,y) coords that should be unlocked given current stats
- Tile definitions are constants (see below); never stored
- Zone derived from coords: (0,0)=home, |x|+|y|≤2=meadow, y≤-3=forest, y≥3=pond, (2,0)=library

```go
var TileDefinitions = []TileDef{
    {X:0, Y:0},                                    // home — always unlocked at registration
    {X:1, Y:0,  CumulativeSteps: 10_000},
    {X:-1,Y:0,  CumulativeSteps: 10_000},
    {X:0, Y:1,  CumulativeSteps: 10_000},
    {X:0, Y:-1, CumulativeSteps: 10_000},
    {X:1, Y:1,  CumulativeSteps: 25_000},
    {X:-1,Y:1,  CumulativeSteps: 25_000},
    {X:1, Y:-1, CumulativeSteps: 25_000},
    {X:-1,Y:-1, CumulativeSteps: 25_000},
    {X:0, Y:-3, StreakDays: 7},
    {X:0, Y:-4, StreakDays: 14},
    {X:0, Y:3,  CumulativeSteps: 20_000},
    {X:1, Y:3,  CumulativeSteps: 40_000},
    {X:-1,Y:3,  CumulativeSteps: 40_000},
    {X:2, Y:0,  ArticlesRead: 5},
    {X:2, Y:-1, ArticlesRead: 20},
}
```

### River engine (`internal/river/engine.go`)
- Input: `lastMessageAt time.Time`
- `level = max(0, 1.0 - days_since*0.10)` — dry after 10 days of silence

---

## WebSocket protocol (all frames are JSON)

```json
{"type":"message","payload":{"id":"…","sender_id":"…","content":"…","sent_at":0}}
{"type":"read","payload":{"message_ids":["…"]}}
{"type":"ping"}
{"type":"pong"}
```

Auth: JWT in `?token=` query param on upgrade. Deliver to recipient immediately if connected.

---

## Visual design tokens

| Token | Value |
|---|---|
| App background | `#FAF8F5` (warm cream) |
| Primary blue | `#4A90D9` |
| Accent green | `#52C78F` |
| Hippo base | `#A8D8EA` |
| Tile meadow | `#A8D5A2` |
| Tile forest | `#4A7C59` |
| Tile pond | `#7EC8E3` |
| Tile library | `#E8D5A3` |
| Tile locked | `#D1D5DB` |
| Font | Nunito, rounded |

## World map: hex tile rendering (Flutter)

Pointy-top hexagons: `ClipPath(clipper: HexClipper())`. Offset-row layout:
- `colSpacing = hexWidth + gap`, `rowSpacing = hexHeight * 0.75 + gap`
- Odd rows offset by `colSpacing / 2`
- Wrapped in `InteractiveViewer` for pan/zoom

## Extensibility: adding sleep data (v2) — 5 files only

1. `internal/health/types.go` — add `SleepHours *float64` to `HealthSummary`
2. `internal/health/service.go` — one `case` in `BuildSummary()`
3. `internal/mood/engine.go` — add sleep score component
4. `app/.../health_summary.dart` — add field + `fromJson`
5. `app/.../health_repository.dart` — add `HealthDataType.SLEEP_ASLEEP`
