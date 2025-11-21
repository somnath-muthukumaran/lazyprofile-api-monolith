package main

import (
	"fmt"
	"log"

	"github.com/gofiber/fiber/v2"
	"github.com/joho/godotenv"
	"github.com/somnath-muthukumaran/lazyprofile/internal/config"
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

	fmt.Printf("✅ Config loaded. App Port: %d, DB Host: %s\n", cfg.AppPort, cfg.DBHost)
	app := fiber.New()

	app.Get("/", func(c *fiber.Ctx) error {
		return c.SendString("Hello, World!")
	})

	listenAddr := fmt.Sprintf(":%d", cfg.AppPort)
	log.Printf("🚀 Fiber server starting on %s", listenAddr)
	if err := app.Listen(listenAddr); err != nil {
		fmt.Printf("Fatal error starting server: %v\n", err)
	}
}
