# MT4 Receiver API Documentation

## Overview

The MT4 Receiver API accepts MT4 account data and stores it in a SQLite database for batch processing to Supabase.

## Endpoints

### GET /

Returns API information and available endpoints.

**Response:**

```json
{
  "name": "MT4 Receiver API",
  "version": "1.0.0",
  "endpoints": {
    "POST /mt4": "Receive MT4 data",
    "GET /health": "Health check",
    "GET /": "API information"
  }
}
```

### GET /health

Returns system health status and uptime.

**Response:**

```json
{
  "status": "ok",
  "timestamp": "2025-12-15T08:19:05.456Z",
  "uptime": 95.803770294
}
```

### POST /mt4

Receives MT4 account data. Uses upsert logic based on `acc_number`.

**Request Body:**

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

**Success Response:**

```json
{
  "success": true,
  "acc_number": 87206682,
  "action": "updated"
}
```

**Error Response:**

```json
{
  "success": false,
  "error": "acc_number is required"
}
```

## Data Validation

- `acc_number` is required and must be a number
- All other fields are optional but recommended
- Data is stored as JSON in the database

## Batch Processing

- Data is automatically sent to Supabase at 15 seconds of every minute
- Only unsent records (`sent = 0`) are processed
- Records are marked as sent (`sent = 1`) after successful transmission
