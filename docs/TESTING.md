# Testing Guide

## API Testing

### Basic API Tests

```bash
make test
```

This will test:

- Health check endpoint
- MT4 data submission
- Account upsert functionality

### Health Check

```bash
make health
```

Shows:

- Container status
- API health
- Database status
- Record counts

## Supabase Testing

### Manual Supabase Test

```bash
# Set environment variables
export SUPABASE_URL="https://your-project.supabase.co/functions/v1/mt4-receiver"
export SUPABASE_TOKEN="your-service-role-key"

# Run test
make test-supabase
```

### Expected Response

```json
{
  "total_received": 1,
  "success_count": 1,
  "error_count": 0,
  "results": [
    {
      "success": true,
      "account_id": 123,
      "acc_number": 99999999,
      "date": "2025.12.15"
    }
  ]
}
```

### Error Response Example

```json
{
  "total_received": 1,
  "success_count": 0,
  "error_count": 1,
  "results": [],
  "errors": [
    {
      "index": 0,
      "acc_number": 99999999,
      "error": "Missing required fields: acc_number or date"
    }
  ]
}
```

## Batch Worker Testing

### Monitor Batch Processing

```bash
# View logs in real-time
make logs

# Look for batch worker messages:
# ℹ️  Batch worker started, sending data at 15 seconds of every minute
# ℹ️  Next batch run in XX seconds
# ℹ️  Batch summary: {...}
# ✅ Batch completed {...}
```

### Force Batch Run

To test batch processing immediately, you can:

1. Send test data:

   ```bash
   make test
   ```

2. Wait for next 15-second mark or restart service:

   ```bash
   make restart
   ```

3. Monitor logs:
   ```bash
   make logs
   ```

## Database Testing

### Check Database Records

```bash
# Access database directly
docker-compose exec mt4-receiver sqlite3 /app/db/data.sqlite

# View all records
SELECT acc_number, created_at, updated_at, sent FROM mt4_queue;

# View pending records
SELECT * FROM mt4_queue WHERE sent = 0;

# View sent records
SELECT * FROM mt4_queue WHERE sent = 1;
```

### Reset Test Data

```bash
# Clear all records
docker-compose exec mt4-receiver sqlite3 /app/db/data.sqlite "DELETE FROM mt4_queue;"

# Reset sent status (for re-testing batch)
docker-compose exec mt4-receiver sqlite3 /app/db/data.sqlite "UPDATE mt4_queue SET sent = 0;"
```

## Troubleshooting

### Common Issues

1. **Port 80 in use**

   ```bash
   # Check what's using port 80
   sudo lsof -i :80

   # Stop conflicting service
   sudo service apache2 stop  # or nginx stop
   ```

2. **Supabase connection failed**

   ```bash
   # Test connection manually
   curl -X POST "https://your-project.supabase.co/functions/v1/mt4-receiver" \
     -H "Content-Type: application/json" \
     -H "Authorization: Bearer your-token" \
     -d '[{"acc_number":123,"date":"2025.12.15"}]'
   ```

3. **Database locked**

   ```bash
   # Restart service
   make restart
   ```

4. **Container won't start**

   ```bash
   # Check logs
   docker-compose logs

   # Rebuild from scratch
   make clean
   make start
   ```

## Performance Testing

### Load Testing

```bash
# Send multiple requests quickly
for i in {1..10}; do
  curl -X POST http://localhost/mt4 \
    -H "Content-Type: application/json" \
    -d "{\"acc_number\":$i,\"date\":\"2025.12.15\",\"balance\":1000}" &
done
wait
```

### Monitor Performance

```bash
# Check system resources
docker stats

# Check response times
time curl -X GET http://localhost/health
```
