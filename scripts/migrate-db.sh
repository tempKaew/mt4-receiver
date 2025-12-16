#!/bin/bash

echo "🔄 Migrating database schema..."

# Stop service first
./scripts/stop.sh

# Remove old database to apply new schema
if [ -f "./db/data.sqlite" ]; then
    echo "�️  Remioving old database (new schema will be created)..."
    rm "./db/data.sqlite"
fi

# Start service to create new schema
./scripts/start.sh

# Wait for service to start
sleep 5

echo "✅ Database migration completed!"
echo "📊 New schema includes:"
echo "   - acc_number column (required)"
echo "   - updated_at column"
echo "   - UNIQUE constraint on acc_number"
echo ""
echo "🧪 Test with new format:"
echo "   ./scripts/test.sh"