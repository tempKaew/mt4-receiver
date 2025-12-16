#!/bin/bash

echo "🚀 Starting MT4 Receiver..."
echo "Building Docker image..."

# Build and start containers
docker-compose up --build -d

echo ""
echo "✅ MT4 Receiver is running!"
echo "📍 API: http://localhost/"
echo "🔍 Health check: http://localhost/health"
echo "📊 View logs: docker-compose logs -f"
echo "🛑 Stop service: ./stop.sh"