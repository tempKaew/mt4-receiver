# Batch Data Format

## Overview

The batch worker sends data to Supabase in the following format every minute at the 15-second mark.

## Request Format

**Method:** POST  
**Headers:**

- `Content-Type: application/json`
- `Authorization: Bearer {SUPABASE_TOKEN}`

**Body Structure:**

```json
[
  {
    "acc_number": 87206682,
    "date": "2025.12.15",
    "balance": 2039.51,
    "equity": 1867.55,
    "current": {
      "total_trade": 68,
      "profit": -171.96,
      "lot": 1.36,
      "order_buy_count": 28,
      "order_sell_count": 28
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
  },
  {
    "acc_number": 87206683,
    "date": "2025.12.15",
    "balance": 1500.0,
    "equity": 1450.25,
    "current": {
      "total_trade": 30,
      "profit": -49.75,
      "lot": 0.8,
      "order_buy_count": 15,
      "order_sell_count": 10
    },
    "history": {
      "total_trade": 5,
      "profit": 25.5,
      "lot": 0.2,
      "order_buy_count": 3,
      "order_sell_count": 2,
      "win": 3,
      "loss": 2
    }
  }
]
```

## Data Processing

1. **Collection Phase (1:00:00 - 1:00:10)**

   - MT4 data is received via POST `/mt4`
   - Data is stored/updated in SQLite based on `acc_number`
   - Records are marked as `sent = 0` (pending)

2. **Batch Phase (1:00:15)**
   - System retrieves all pending records (`sent = 0`)
   - Converts JSON strings back to objects
   - Sends array of objects to Supabase
   - Marks records as `sent = 1` on success

## Batch Summary Logging

The system logs a summary before sending:

```json
{
  "records": 2,
  "accounts": 2,
  "account_numbers": [87206682, 87206683],
  "total_balance": "3539.51",
  "total_equity": "3317.80",
  "sample_record": {
    "acc_number": 87206682,
    "date": "2025.12.15",
    "balance": 2039.51,
    "equity": 1867.55,
    "current": { ... },
    "history": { ... }
  }
}
```

## Error Handling

- **Network Errors:** Logged but records remain unsent for retry
- **Authentication Errors:** Logged with status code
- **Validation Errors:** Individual records may be skipped
- **Timeout:** Configurable timeout for HTTP requests

## Timing

- **Frequency:** Every minute at 15 seconds (1:00:15, 2:00:15, etc.)
- **Batch Size:** Maximum 50 records per batch
- **Retry:** Failed batches remain in queue for next cycle
