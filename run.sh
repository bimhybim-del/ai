#!/bin/bash
UA="Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/131.0.0.0 Safari/537.36"

# Use the MOST RECENTLY created account (from v26) — org 50 already exists
KEY="5da1b5ae6b74de3bbaee92e1e979e1ffd39c0d67"

# FIRST REQUEST: Create ADMIN invite (Issue #4681)
echo "=== ADMIN INVITE (FIRST REQUEST) ==="
curl -s -X POST "https://flagsmith.koinworks.com/api/v1/organisations/50/invites/" \
  -H "Authorization: Token $KEY" -H "Content-Type: application/json" -H "User-Agent: $UA" \
  -d '{"email":"kw-admin-test@proton.me","role":"ADMIN","frontend_base_url":"https://flagsmith.koinworks.com"}' --max-time 15
echo ""

# SECOND: Try alternate invite endpoint format  
echo "=== INVITE V2 ==="
curl -s -X POST "https://flagsmith.koinworks.com/api/v1/organisations/50/invite/" \
  -H "Authorization: Token $KEY" -H "Content-Type: application/json" -H "User-Agent: $UA" \
  -d '{"email":"kw-admin-v3@proton.me","role":"ADMIN"}' --max-time 15
echo ""

# THIRD: Check our user role in org
echo "=== ORG ROLE ==="
curl -s "https://flagsmith.koinworks.com/api/v1/organisations/50/" \
  -H "Authorization: Token $KEY" -H "User-Agent: $UA" --max-time 10 | python3 -c "
import json,sys
d = json.load(sys.stdin)
print(f'Role: {d.get(\"role\",\"?\")}')
print(f'Name: {d.get(\"name\",\"?\")}')
" 2>/dev/null
