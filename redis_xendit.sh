#!/bin/bash
export PATH="/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin"

/usr/bin/sshpass -p kutul0nc4t ssh -o StrictHostKeyChecking=no -o ConnectTimeout=10 user@10.13.16.196 bash << 'REMOTECMD'
export PATH="/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin"

echo "=== REDIS XENDIT KEY SCAN ==="
# Scan Redis for xendit/xnd keys
redis-cli -h 10.13.16.156 -p 6379 --scan --pattern '*xendit*' 2>/dev/null | head -50
redis-cli -h 10.13.16.156 -p 6379 --scan --pattern '*xnd*' 2>/dev/null | head -50
redis-cli -h 10.13.16.156 -p 6379 --scan --pattern '*payment*key*' 2>/dev/null | head -50

echo "=== REDIS KEY TYPES ==="
redis-cli -h 10.13.16.156 -p 6379 --scan --pattern '*xendit*' 2>/dev/null | while read key; do
  echo "KEY: $key"
  TYPE=$(redis-cli -h 10.13.16.156 -p 6379 type "$key" 2>/dev/null)
  echo "TYPE: $TYPE"
  case "$TYPE" in
    string) redis-cli -h 10.13.16.156 -p 6379 get "$key" 2>/dev/null | head -c 500; echo ;;
    hash) redis-cli -h 10.13.16.156 -p 6379 hgetall "$key" 2>/dev/null | head -20 ;;
    list) redis-cli -h 10.13.16.156 -p 6379 lrange "$key" 0 10 2>/dev/null ;;
    set) redis-cli -h 10.13.16.156 -p 6379 smembers "$key" 2>/dev/null | head -20 ;;
    *) echo "Unknown type: $TYPE" ;;
  esac
  echo "---"
done

echo "=== REDIS RANDOM SAMPLE (10 keys) ==="
for i in $(seq 1 10); do
  KEY=$(redis-cli -h 10.13.16.156 -p 6379 randomkey 2>/dev/null)
  echo "KEY: $KEY"
  TYPE=$(redis-cli -h 10.13.16.156 -p 6379 type "$KEY" 2>/dev/null)
  echo "TYPE: $TYPE"
  case "$TYPE" in
    string) redis-cli -h 10.13.16.156 -p 6379 get "$KEY" 2>/dev/null | head -c 200; echo ;;
    *) echo "non-string type" ;;
  esac
  echo "---"
done

echo "=== REDIS DB INFO ==="
redis-cli -h 10.13.16.156 -p 6379 info keyspace 2>/dev/null

echo "=== REDIS CONFIG ==="
redis-cli -h 10.13.16.156 -p 6379 info server 2>/dev/null | head -10

echo "=== DONE ==="
REMOTECMD
