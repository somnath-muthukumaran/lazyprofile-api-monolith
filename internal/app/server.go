package app

import (
	"github.com/gofiber/fiber/v2"
	"github.com/gofiber/fiber/v2/middleware/logger"
	"github.com/gofiber/fiber/v2/middleware/recover"
	"github.com/somnath-muthukumaran/lazyprofile/internal/handlers"
)

func New(postHandler *handlers.PostHandler) *fiber.App {
	app := fiber.New(fiber.Config{
		AppName: "My Product CMS",
	})

	// 1. Global Middleware
	app.Use(recover.New()) // Prevents crashes
	app.Use(logger.New())  // Logs requests

	// 2. Setup Routes
	setupRoutes(app, postHandler)

	return app
}

func setupRoutes(app *fiber.App, postHandler *handlers.PostHandler) {
	app.Get("/health", func(c *fiber.Ctx) error {
		return c.Status(fiber.StatusOK).JSON(fiber.Map{"status": "ok"})
	})

	// API Group
	api := app.Group("/api/v1")

	// Post Domain Routes
	posts := api.Group("/posts")
	posts.Post("/", postHandler.Create)
	posts.Get("/:id", postHandler.GetByID)
}
