# Database Documentation

## Schema

### Table: mt4_queue

```sql
CREATE TABLE mt4_queue (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    acc_number INTEGER NOT NULL,
    payload TEXT,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    sent INTEGER DEFAULT 0,
    UNIQUE(acc_number)
);
```

## Fields

- **id**: Auto-incrementing primary key
- **acc_number**: MT4 account number (unique, required)
- **payload**: JSON string containing MT4 data
- **created_at**: Record creation timestamp
- **updated_at**: Last update timestamp
- **sent**: Flag indicating if data was sent to Supabase (0=pending, 1=sent)

## Operations

### Upsert Logic

The system uses `INSERT OR REPLACE` to handle account updates:

```sql
INSERT OR REPLACE INTO mt4_queue (acc_number, payload, updated_at, sent)
VALUES (?, ?, CURRENT_TIMESTAMP, 0)
```

### Batch Processing

Pending records are selected for batch processing:

```sql
SELECT * FROM mt4_queue WHERE sent = 0 LIMIT 50
```

After successful transmission, records are marked as sent:

```sql
UPDATE mt4_queue SET sent=1 WHERE id IN (...)
```

## Maintenance

### Manual Queries

```bash
# Access database
docker-compose exec mt4-receiver sqlite3 /app/db/data.sqlite

# View all accounts
SELECT acc_number, created_at, updated_at, sent FROM mt4_queue;

# View pending records
SELECT * FROM mt4_queue WHERE sent = 0;

# View sent records
SELECT * FROM mt4_queue WHERE sent = 1;

# Reset sent status (for testing)
UPDATE mt4_queue SET sent = 0;

# Delete old records
DELETE FROM mt4_queue WHERE created_at < datetime('now', '-30 days');
```

### Backup and Restore

```bash
# Create backup
make backup

# List backups
ls -la backups/

# Restore from backup
make restore
```

### Migration

When upgrading from old schema:

```bash
make migrate
```

This will:

1. Stop the service
2. Remove old database
3. Start service (creates new schema)
4. Ready for new data format

## Performance

- Database is stored on host filesystem (persistent)
- SQLite handles concurrent reads well
- Batch processing limits to 50 records per run
- Unique constraint on acc_number prevents duplicates

## Monitoring

Check database status:

```bash
# Database size
du -h db/data.sqlite

# Record counts
make health
```
