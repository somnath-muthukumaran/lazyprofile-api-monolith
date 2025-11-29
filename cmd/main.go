package main

import (
	"fmt"
	"log"

	"github.com/joho/godotenv"
	"github.com/somnath-muthukumaran/lazyprofile/internal/app"
	"github.com/somnath-muthukumaran/lazyprofile/internal/config"
	"github.com/somnath-muthukumaran/lazyprofile/internal/handlers"
	"github.com/somnath-muthukumaran/lazyprofile/pkg/database"
	"github.com/somnath-muthukumaran/lazyprofile/pkg/firebaseclient"
)

func init() {
	if err := godotenv.Load(); err != nil {
		fmt.Println("⚠️ Warning: No .env file found or unable to load.")
	}
}

func main() {
	if err := config.LoadConfig(); err != nil {
		log.Fatalf("❌ Configuration error: %v", err)
	}
	cfg := config.GetConfig()
	fmt.Printf("✅ Config loaded")

	if err := firebaseclient.InitFirebase(cfg); err != nil {
		log.Fatalf("❌ Failed to initialize firebase error: %v", err)
	}

	pool, err := database.ConnectPostgres(cfg)
	if err != nil {
		log.Fatalf("Could not connect to database: %v", err)
	}
	defer pool.Close()
	// queries := db.New(pool)

	postHandler := handlers.NewPostHandler( /* postService */ )

	handlersContainer := &app.Handlers{
		PostHandler: postHandler,
	}

	application := app.New(handlersContainer)
	listenAddr := fmt.Sprintf(":%d", cfg.AppPort)
	log.Printf("🚀 Fiber server starting on %s", listenAddr)

	if err := application.Listen(listenAddr); err != nil {
		fmt.Printf("Fatal error starting server: %v\n", err)
	}
}
