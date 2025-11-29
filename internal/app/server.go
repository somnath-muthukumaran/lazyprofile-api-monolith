package app

import (
	"github.com/gofiber/fiber/v2"
	"github.com/gofiber/fiber/v2/middleware/logger"
	"github.com/gofiber/fiber/v2/middleware/recover"
	"github.com/somnath-muthukumaran/lazyprofile/internal/handlers"
)

type Handlers struct {
	PostHandler *handlers.PostHandler
}

func New(h *Handlers) *fiber.App {
	app := fiber.New(fiber.Config{
		AppName: "Lazy Profile CMS",
	})

	app.Use(recover.New())
	app.Use(logger.New())
	setupRoutes(app, h)

	return app
}

func setupRoutes(app *fiber.App, h *Handlers) {
	app.Get("/health", func(c *fiber.Ctx) error {
		return c.Status(fiber.StatusOK).JSON(fiber.Map{"status": "ok"})
	})

	api := app.Group("/api/v1")

	posts := api.Group("/posts")
	posts.Post("/", h.PostHandler.Create)
	posts.Get("/:id", h.PostHandler.GetByID)
}
