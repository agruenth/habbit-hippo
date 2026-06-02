package main

import (
	"log"
	"net/http"

	"github.com/go-chi/chi/v5"
	chimw "github.com/go-chi/chi/v5/middleware"

	"github.com/agruenth/habbit-hippo/backend/internal/article"
	"github.com/agruenth/habbit-hippo/backend/internal/auth"
	"github.com/agruenth/habbit-hippo/backend/internal/chat"
	"github.com/agruenth/habbit-hippo/backend/internal/config"
	"github.com/agruenth/habbit-hippo/backend/internal/db"
	"github.com/agruenth/habbit-hippo/backend/internal/friend"
	"github.com/agruenth/habbit-hippo/backend/internal/habit"
	"github.com/agruenth/habbit-hippo/backend/internal/health"
	"github.com/agruenth/habbit-hippo/backend/internal/hippo"
)

func main() {
	cfg := config.Load()

	database, err := db.Open(cfg.DBPath)
	if err != nil {
		log.Fatalf("open db: %v", err)
	}
	defer database.Close()

	authSvc    := auth.NewService(database, cfg.JWTSecret)
	healthSvc  := health.NewService(database)
	habitSvc   := habit.NewService(database)
	hippoSvc   := hippo.NewService(database, healthSvc, habitSvc)
	articleSvc := article.NewService(database)
	friendSvc  := friend.NewService(database)
	chatHub    := chat.NewHub(database)

	r := chi.NewRouter()
	r.Use(chimw.Logger)
	r.Use(chimw.Recoverer)
	r.Use(chimw.RequestID)
	r.Use(chimw.RealIP)

	// Public
	r.Post("/auth/register", auth.HandleRegister(authSvc))
	r.Post("/auth/login",    auth.HandleLogin(authSvc))
	r.Post("/auth/refresh",  auth.HandleRefresh(authSvc))
	r.Get("/article/today",  article.HandleToday(articleSvc)) // public — no auth needed to preview

	// Protected
	r.Group(func(r chi.Router) {
		r.Use(auth.JWTMiddleware(cfg.JWTSecret))

		// Hippo
		r.Get("/hippo",  hippo.HandleGet(hippoSvc))
		r.Put("/hippo",  hippo.HandleUpdate(hippoSvc))

		// Health
		r.Post("/health/sync",    health.HandleSync(healthSvc))
		r.Get("/health/summary",  health.HandleSummary(healthSvc))

		// Habits
		r.Get("/habits",              habit.HandleList(habitSvc))
		r.Post("/habits",             habit.HandleCreate(habitSvc))
		r.Post("/habits/{id}/log",    habit.HandleLog(habitSvc))
		r.Get("/habits/history",      habit.HandleHistory(habitSvc))

		// Articles
		r.Post("/article/log",  article.HandleLog(articleSvc))
		r.Get("/article/stats", article.HandleStats(articleSvc))

		// Friends
		r.Get("/friends",                  friend.HandleList(friendSvc))
		r.Post("/friends/request",         friend.HandleRequest(friendSvc))
		r.Get("/friends/pending",          friend.HandlePending(friendSvc))
		r.Post("/friends/{id}/respond",    friend.HandleRespond(friendSvc))
		r.Delete("/friends/{id}",          friend.HandleRemove(friendSvc))

		// Chat (HTTP + WebSocket)
		r.Get("/chat/{friendID}",   chat.HandleGetMessages(chatHub))
		r.Post("/chat/{friendID}",  chat.HandleSendMessage(chatHub))
		r.Get("/ws",                chat.HandleWS(chatHub))
	})

	log.Printf("listening on %s", cfg.Addr)
	if err := http.ListenAndServe(cfg.Addr, r); err != nil {
		log.Fatalf("server error: %v", err)
	}
}
