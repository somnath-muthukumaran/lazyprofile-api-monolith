package middlewares

import (
	"context"
	"strings"

	"github.com/gofiber/fiber/v2"
	"github.com/somnath-muthukumaran/lazyprofile/internal/config"
)

func AuthMiddleware(c *fiber.Ctx) error {
	authHeader := c.Get("Authorization")
	if authHeader == "" {
		return c.Status(fiber.StatusUnauthorized).JSON(fiber.Map{
			"error": "Missing Authorization header",
		})
	}

	idToken := strings.TrimSpace(strings.Replace(authHeader, "Bearer", "", 1))
	if idToken == "" {
		return c.Status(fiber.StatusUnauthorized).JSON(fiber.Map{
			"error": "Invalid token format",
		})
	}

	token, err := config.AuthClient.VerifyIDToken(context.Background(), idToken)
	if err != nil {
		return c.Status(fiber.StatusUnauthorized).JSON(fiber.Map{
			"error": "Invalid or expired token",
		})
	}
	c.Locals("user_id", token.UID)
	c.Locals("email", token.Claims["email"])
	return c.Next()
}
