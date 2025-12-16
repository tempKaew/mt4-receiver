#!/bin/bash

echo "Testing MT4 Receiver API..."

echo "1. Health check:"
curl -X GET http://localhost/health
echo -e "\n"

echo "2. Sending test MT4 data (Account 87206682):"
curl -X POST http://localhost/mt4 \
  -H "Content-Type: application/json" \
  -d '{"acc_number":87206682,"date":"2025.12.15","balance":2039.51,"equity":1902.75,"current":{"total_trade":60,"profit":-136.76,"lot":1.2,"order_buy_count":24,"order_sell_count":20},"history":{"total_trade":0,"profit":0,"lot":0,"order_buy_count":0,"order_sell_count":0,"win":0,"loss":0}}'
echo -e "\n"

echo "3. Sending another test record (Account 87206683):"
curl -X POST http://localhost/mt4 \
  -H "Content-Type: application/json" \
  -d '{"acc_number":87206683,"date":"2025.12.15","balance":1500.00,"equity":1450.25,"current":{"total_trade":30,"profit":-49.75,"lot":0.8,"order_buy_count":15,"order_sell_count":10},"history":{"total_trade":5,"profit":25.50,"lot":0.2,"order_buy_count":3,"order_sell_count":2,"win":3,"loss":2}}'
echo -e "\n"

echo "4. Updating first account (same acc_number):"
curl -X POST http://localhost/mt4 \
  -H "Content-Type: application/json" \
  -d '{"acc_number":87206682,"date":"2025.12.15","balance":2050.00,"equity":1920.00,"current":{"total_trade":62,"profit":-130.00,"lot":1.3,"order_buy_count":25,"order_sell_count":21},"history":{"total_trade":0,"profit":0,"lot":0,"order_buy_count":0,"order_sell_count":0,"win":0,"loss":0}}'
echo -e "\n"

echo "Test completed! Data is stored in SQLite and will be sent to Supabase every 60 seconds."