#!/bin/bash
# Local Build and Run Script

echo "🚀 Building CeyGo Backend..."
docker compose build

echo "📦 Starting Services..."
docker compose up -d

echo "⏳ Waiting for Database to be ready..."
sleep 5

echo "🔄 Running Migrations..."
docker compose exec backend npm run migration:up

echo "✅ Deployment successful!"
echo "📍 Health check: http://localhost:3000/api/v1/health"
