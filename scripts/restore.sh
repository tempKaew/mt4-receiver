#!/bin/bash

BACKUP_DIR="./backups"

# Check if backup directory exists
if [ ! -d "$BACKUP_DIR" ]; then
    echo "❌ Backup directory not found: $BACKUP_DIR"
    exit 1
fi

# List available backups
echo "📁 Available backups:"
ls -la $BACKUP_DIR/data_backup_*.sqlite 2>/dev/null

if [ $? -ne 0 ]; then
    echo "❌ No backup files found"
    exit 1
fi

echo ""
echo "Enter the backup filename to restore (or press Enter for latest):"
read BACKUP_FILE

# If no input, use latest backup
if [ -z "$BACKUP_FILE" ]; then
    BACKUP_FILE=$(ls -t $BACKUP_DIR/data_backup_*.sqlite | head -n 1)
    echo "Using latest backup: $(basename $BACKUP_FILE)"
fi

# Check if backup file exists
if [ ! -f "$BACKUP_DIR/$BACKUP_FILE" ] && [ ! -f "$BACKUP_FILE" ]; then
    echo "❌ Backup file not found"
    exit 1
fi

# Determine full path
if [ -f "$BACKUP_DIR/$BACKUP_FILE" ]; then
    FULL_PATH="$BACKUP_DIR/$BACKUP_FILE"
else
    FULL_PATH="$BACKUP_FILE"
fi

# Stop service before restore
echo "🛑 Stopping MT4 Receiver..."
./scripts/stop.sh

# Create db directory if not exists
mkdir -p ./db

# Restore database
cp "$FULL_PATH" "./db/data.sqlite"
echo "✅ Database restored from: $FULL_PATH"

# Start service
echo "🚀 Starting MT4 Receiver..."
./scripts/start.sh