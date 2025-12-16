#!/bin/bash

# Create backup directory
BACKUP_DIR="./backups"
mkdir -p $BACKUP_DIR

# Generate timestamp
TIMESTAMP=$(date +"%Y%m%d_%H%M%S")

# Backup database
if [ -f "./db/data.sqlite" ]; then
    cp "./db/data.sqlite" "$BACKUP_DIR/data_backup_$TIMESTAMP.sqlite"
    echo "✅ Database backed up to: $BACKUP_DIR/data_backup_$TIMESTAMP.sqlite"
    
    # Keep only last 10 backups
    ls -t $BACKUP_DIR/data_backup_*.sqlite | tail -n +11 | xargs -r rm
    echo "🧹 Old backups cleaned up (keeping last 10)"
else
    echo "❌ Database file not found: ./db/data.sqlite"
fi

# Show backup files
echo ""
echo "📁 Available backups:"
ls -la $BACKUP_DIR/data_backup_*.sqlite 2>/dev/null || echo "No backups found"