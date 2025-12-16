#!/bin/bash

echo "🛑 Stopping MT4 Receiver..."

# Stop and remove containers
docker-compose down

echo "✅ MT4 Receiver stopped successfully!"