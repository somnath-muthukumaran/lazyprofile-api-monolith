#!/bin/bash

PROJECT_NAME=$(basename "$PWD")
MODULE_NAME="post"

create_dir() {
    if [ ! -d "$1" ]; then
        if mkdir -p "$1"; then
            echo "✅ Directory created: $1"
        else
            echo "❌ Failed to create directory: $1"
            exit 1
        fi
    fi
}

create_file() {
    if [ ! -f "$1" ]; then
        touch "$1"
        echo "  -> File created: $1"
    fi
}

echo "🚀 Starting setup for project in current directory: $PROJECT_NAME"
echo "---"

create_dir "cmd"
create_dir "pkg/utils"
create_dir "internal/app"
create_dir "internal/config"
create_dir "internal/domain"
create_dir "internal/handlers"
create_dir "internal/repositories"
create_dir "internal/services"
create_dir "web"
create_dir "scripts"
create_dir "migrations"

echo ""
echo "📝 Creating placeholder files..."


create_file "cmd/main.go"
create_file "pkg/utils/errors.go"
create_file "internal/app/server.go"
create_file "internal/config/config.go"
create_file "internal/domain/${MODULE_NAME}.go"
create_file "internal/handlers/${MODULE_NAME}_handler.go"
create_file "internal/repositories/${MODULE_NAME}_repo.go"
create_file "internal/services/${MODULE_NAME}_service.go"
create_file "Dockerfile"
create_file "go.mod"
create_file "README.md"

echo "---"
echo "🎉 Setup Complete!"
echo "Project structure created in the current directory: '$PROJECT_NAME'."
echo "Next Steps:"
echo "1. Run 'go mod init [YOUR_MODULE_PATH]' (e.g., go mod init github.com/user/$PROJECT_NAME)"
echo "2. Start coding in internal/config/config.go!"
