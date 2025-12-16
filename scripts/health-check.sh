#!/bin/bash

echo "🔍 MT4 Receiver Health Check"
echo "=========================="

# Check if container is running
if docker-compose ps | grep -q "Up"; then
    echo "✅ Container: Running"
else
    echo "❌ Container: Not running"
    exit 1
fi

# Check API health
HTTP_STATUS=$(curl -s -o /dev/null -w "%{http_code}" http://localhost/health)
if [ "$HTTP_STATUS" = "200" ]; then
    echo "✅ API: Healthy"
    curl -s http://localhost/health | jq '.' 2>/dev/null || curl -s http://localhost/health
else
    echo "❌ API: Not responding (HTTP $HTTP_STATUS)"
fi

# Check database file
if [ -f "./db/data.sqlite" ]; then
    DB_SIZE=$(du -h "./db/data.sqlite" | cut -f1)
    echo "✅ Database: Exists ($DB_SIZE)"
    
    # Count records in database
    RECORD_COUNT=$(docker-compose exec -T mt4-receiver sqlite3 /app/db/data.sqlite "SELECT COUNT(*) FROM mt4_queue;" 2>/dev/null)
    if [ $? -eq 0 ]; then
        echo "📊 Total records: $RECORD_COUNT"
        
        PENDING_COUNT=$(docker-compose exec -T mt4-receiver sqlite3 /app/db/data.sqlite "SELECT COUNT(*) FROM mt4_queue WHERE sent = 0;" 2>/dev/null)
        SENT_COUNT=$(docker-compose exec -T mt4-receiver sqlite3 /app/db/data.sqlite "SELECT COUNT(*) FROM mt4_queue WHERE sent = 1;" 2>/dev/null)
        
        echo "📤 Pending: $PENDING_COUNT"
        echo "✅ Sent: $SENT_COUNT"
    fi
else
    echo "❌ Database: File not found"
fi

# Check disk space
DISK_USAGE=$(df -h . | tail -1 | awk '{print $5}')
echo "💾 Disk usage: $DISK_USAGE"

echo ""
echo "🔗 Quick links:"
echo "   API Info: http://localhost/"
echo "   Health: http://localhost/health"