#!/bin/bash

echo "🧪 Testing Supabase Connection..."

# Check if environment variables are set
if [ -z "$SUPABASE_URL" ] || [ -z "$SUPABASE_TOKEN" ]; then
    echo "❌ Environment variables not set"
    echo "Please set SUPABASE_URL and SUPABASE_TOKEN"
    echo ""
    echo "Example:"
    echo "export SUPABASE_URL='https://your-project.supabase.co/functions/v1/mt4-receiver'"
    echo "export SUPABASE_TOKEN='your-service-role-key'"
    exit 1
fi

echo "📡 Sending test data to Supabase..."

# Test data
TEST_DATA='[
  {
    "acc_number": 99999999,
    "date": "2025.12.15",
    "balance": 1000.00,
    "equity": 950.00,
    "current": {
      "total_trade": 5,
      "profit": -50.00,
      "lot": 0.5,
      "order_buy_count": 3,
      "order_sell_count": 2
    },
    "history": {
      "total_trade": 10,
      "profit": 100.00,
      "lot": 1.0,
      "order_buy_count": 6,
      "order_sell_count": 4,
      "win": 7,
      "loss": 3
    }
  }
]'

# Send request
RESPONSE=$(curl -s -w "\nHTTP_STATUS:%{http_code}" \
  -X POST "$SUPABASE_URL" \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $SUPABASE_TOKEN" \
  -d "$TEST_DATA")

# Parse response
HTTP_BODY=$(echo "$RESPONSE" | sed -E 's/HTTP_STATUS\:[0-9]{3}$//')
HTTP_STATUS=$(echo "$RESPONSE" | tr -d '\n' | sed -E 's/.*HTTP_STATUS:([0-9]{3})$/\1/')

echo "📊 Response Status: $HTTP_STATUS"
echo "📄 Response Body:"
echo "$HTTP_BODY" | jq '.' 2>/dev/null || echo "$HTTP_BODY"

if [ "$HTTP_STATUS" = "200" ]; then
    echo "✅ Supabase connection successful!"
else
    echo "❌ Supabase connection failed!"
fi