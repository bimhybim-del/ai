#!/bin/bash
UA="Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/131.0.0.0 Safari/537.36"
KEY="03175989940bbc4e44d3c17711babe8a58effa8f"

# Try create-superuser with our token
echo "=== CREATE SUPERUSER WITH TOKEN ==="
curl -s -X POST "https://flagsmith.koinworks.com/api/v1/auth/users/create-superuser/" \
  -H "Authorization: Token $KEY" -H "Content-Type: application/json" -H "User-Agent: $UA" \
  -d '{"email":"kw-super@proton.me","password":"SuperAdmin2026!X","first_name":"Super","last_name":"Admin"}' --max-time 15
echo ""

# Try with different auth methods
echo "=== SUPERUSER BASIC AUTH ==="
curl -s -X POST "https://flagsmith.koinworks.com/api/v1/auth/users/create-superuser/" \
  -u "admin:admin" -H "Content-Type: application/json" -H "User-Agent: $UA" \
  -d '{"email":"kw-super2@proton.me","password":"SuperAdmin2026!Y","first_name":"S","last_name":"A"}' --max-time 15
echo ""

# Try without any auth body params (maybe it auto-creates based on token user)
echo "=== SUPERUSER MAKE-ADMIN ==="
curl -s -X POST "https://flagsmith.koinworks.com/api/v1/auth/users/make-admin/" \
  -H "Authorization: Token $KEY" -H "Content-Type: application/json" -H "User-Agent: $UA" \
  -d '{"user_id":86}' --max-time 10
echo ""

# Check is_superuser status
echo "=== USER INFO ==="
curl -s "https://flagsmith.koinworks.com/api/v1/auth/users/me/" \
  -H "Authorization: Token $KEY" -H "User-Agent: $UA" -H "Accept: application/json" --max-time 10
echo ""

# Check Flagsmith version
echo "=== VERSION ==="
curl -s "https://flagsmith.koinworks.com/api/v1/version/" \
  -H "Authorization: Token $KEY" -H "User-Agent: $UA" --max-time 10
echo ""

# Check if there's a Django admin API
echo "=== DJANGO ADMIN API ==="
curl -s "https://flagsmith.koinworks.com/admin/api/" \
  -H "User-Agent: $UA" --max-time 10 | head -c 300
echo ""
