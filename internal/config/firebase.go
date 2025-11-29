package config

import (
	"context"
	"encoding/base64"
	"fmt"

	firebase "firebase.google.com/go/v4"
	"firebase.google.com/go/v4/auth"
	"google.golang.org/api/option"
)

var FirebaseApp *firebase.App
var AuthClient *auth.Client

func InitFirebase() error {

	ctx := context.Background()
	appConstants := GetConfig()
	if appConstants.FirebaseCredentialsJSONBase64 == "" {
		return fmt.Errorf("FIREBASE_CREDENTIALS_JSON environment variable is not set")
	}

	credsJSON, err := base64.StdEncoding.DecodeString(appConstants.FirebaseCredentialsJSONBase64)
	if err != nil {
		return fmt.Errorf("failed to decode firebase credentials: %v", err)
	}
	opt := option.WithCredentialsJSON(credsJSON)

	app, err := firebase.NewApp(ctx, nil, opt)
	if err != nil {
		return fmt.Errorf("error initializing app: %v", err)
	}
	FirebaseApp = app

	client, err := app.Auth(ctx)
	if err != nil {
		return fmt.Errorf("error getting Auth client: %v", err)
	}
	AuthClient = client

	return nil
}
