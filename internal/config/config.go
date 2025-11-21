package config

import (
	"fmt"
	"os"
	"strconv"
)

var appConfig *Config

type Config struct {
	AppPort int
	DBHost  string
	DBPort  int
	DBUser  string
	DBPass  string
	DBName  string
}

func LoadConfig() error {

	portStr := os.Getenv("APP_PORT")
	if portStr == "" {
		portStr = "3000"
	}
	appPort, err := strconv.Atoi(portStr)
	if err != nil {
		return fmt.Errorf("invalid APP_PORT: %w", err)
	}

	dbPortStr := os.Getenv("DB_PORT")
	if dbPortStr == "" {
		dbPortStr = "5432"
	}
	dbPort, err := strconv.Atoi(dbPortStr)
	if err != nil {
		return fmt.Errorf("invalid DB_PORT: %w", err)
	}

	appConfig = &Config{
		AppPort: appPort,
		DBHost:  os.Getenv("DB_HOST"),
		DBPort:  dbPort,
		DBUser:  os.Getenv("DB_USER"),
		DBPass:  os.Getenv("DB_PASS"),
		DBName:  os.Getenv("DB_NAME"),
	}

	if appConfig.DBUser == "" || appConfig.DBPass == "" || appConfig.DBName == "" {
		return fmt.Errorf("database credentials (DB_USER, DB_PASS, DB_NAME) must be set in .env")
	}

	return nil
}

func GetConfig() Config {
	if appConfig == nil {
		panic("Config not loaded. Call LoadConfig() first.")
	}
	return *appConfig
}
