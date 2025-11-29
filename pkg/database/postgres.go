package database

import (
	"context"
	"fmt"
	"log"
	"time"

	"github.com/jackc/pgx/v5/pgxpool"
	"github.com/somnath-muthukumaran/lazyprofile/internal/config"
)

func ConnectPostgres(cfg config.Config) (*pgxpool.Pool, error) {
	connStr := fmt.Sprintf("host=%s port=%d dbname=%s user=%s password=%s",
		cfg.DBHost, cfg.DBPort, cfg.DBName, cfg.DBUser, cfg.DBPass)
	config, err := pgxpool.ParseConfig(connStr)

	if err != nil {
		return nil, fmt.Errorf("failed to parse config: %w", err)
	}

	config.MaxConns = cfg.DBMaxConns
	config.MinConns = cfg.DBMinConns
	config.MaxConnLifetime = cfg.DBMaxConnLifetime
	config.MaxConnIdleTime = cfg.DBMaxConnIdleTime

	ctx, cancel := context.WithTimeout(context.Background(), 5*time.Second)
	defer cancel()

	pool, err := pgxpool.NewWithConfig(ctx, config)
	if err != nil {
		return nil, fmt.Errorf("failed to create pool: %w", err)
	}
	if err := pool.Ping(ctx); err != nil {
		return nil, fmt.Errorf("failed to ping database: %w", err)
	}

	log.Println("Successfully connected to PostgreSQL via pgxpool")
	return pool, nil
}
