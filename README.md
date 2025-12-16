# MT4 Receiver

A minimal Docker-based service that receives MT4 data via POST requests and forwards it to Supabase.

## Features

- Receives MT4 account data via POST `/mt4` endpoint
- Stores data in SQLite database with account-based upsert
- Automatically sends data to Supabase at 15 seconds of every minute
- Runs on port 80 via Docker
- Account-based data management (update existing, insert new)

## Quick Start

```bash
# Start the service
make start

# Test the API
make test

# Check system health
make health

# Stop the service
make stop
```

## Setup

1. Copy environment variables:

   ```bash
   cp api/.env.example api/.env
   ```

2. Edit `api/.env` with your Supabase credentials:

   ```env
   SUPABASE_URL=https://your-project.supabase.co/rest/v1/your-table
   SUPABASE_TOKEN=your-service-role-key
   ```

3. Start the service:

   ```bash
   make start
   ```

4. Access the service at `http://localhost/`

## Available Commands

Run `make help` to see all available commands:

```bash
make start     # Start the service
make stop      # Stop the service
make restart   # Restart the service
make test      # Run API tests
make health    # Check system health
make backup    # Backup database
make restore   # Restore database
make migrate   # Migrate database schema
make logs      # View service logs
make clean     # Clean up containers and images
```

## API Endpoints

- `GET /` - API information
- `POST /mt4` - Receive MT4 account data (requires acc_number)
- `GET /health` - Health check with uptime

## Data Format

The `/mt4` endpoint expects data in this format:

```json
{
  "acc_number": 87206682,
  "date": "2025.12.15",
  "balance": 2039.51,
  "equity": 1902.75,
  "current": {
    "total_trade": 60,
    "profit": -136.76,
    "lot": 1.2,
    "order_buy_count": 24,
    "order_sell_count": 20
  },
  "history": {
    "total_trade": 0,
    "profit": 0,
    "lot": 0,
    "order_buy_count": 0,
    "order_sell_count": 0,
    "win": 0,
    "loss": 0
  }
}
```

## Batch Processing

- Data is sent to Supabase at **15 seconds** of every minute (e.g., 1:00:15, 2:00:15)
- This timing ensures data collection completes before batch processing
- Only unsent data (`sent = 0`) is processed

## Project Structure

```
├── api/                 # Application code
│   ├── server.js        # Main server entry point
│   ├── config.js        # Configuration settings
│   ├── database.js      # SQLite database functions
│   ├── routes.js        # API routes
│   ├── batch-worker.js  # Supabase batch sender
│   ├── package.json     # Dependencies
│   ├── Dockerfile       # Docker configuration
│   ├── .env            # Environment variables
│   └── .env.example    # Environment template
├── scripts/             # Management scripts
│   ├── start.sh         # Start service
│   ├── stop.sh          # Stop service
│   ├── test.sh          # API tests
│   ├── backup.sh        # Database backup
│   ├── restore.sh       # Database restore
│   ├── migrate-db.sh    # Database migration
│   └── health-check.sh  # System health check
├── docs/                # Documentation
│   ├── API.md           # API documentation
│   ├── DATABASE.md      # Database documentation
│   └── DEPLOYMENT.md    # Deployment guide
├── db/                  # SQLite database volume
├── docker-compose.yml   # Docker Compose configuration
└── Makefile            # Command shortcuts
```

## Documentation

- [API Documentation](docs/API.md) - Detailed API reference
- [Database Documentation](docs/DATABASE.md) - Database schema and queries
- [Deployment Guide](docs/DEPLOYMENT.md) - Production deployment guide
- [Batch Format](docs/BATCH-FORMAT.md) - Supabase batch data format
- [Testing Guide](docs/TESTING.md) - Testing and troubleshooting

## Migration

If upgrading from old schema, run:

```bash
make migrate
```

## License

MIT License
