#!/bin/bash
export PATH="/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin"

/usr/bin/sshpass -p kutul0nc4t ssh -o StrictHostKeyChecking=no -o ConnectTimeout=10 user@10.13.16.132 bash << 'REMOTECMD'
export PATH="/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin"

echo "=== ACCURATE JAVA PROCESSES ==="
ps aux | grep java | grep -v grep | head -5

echo "=== ACCURATE CONFIG FILES ==="
echo kutul0nc4t | sudo -S find /progs -name "*.properties" -o -name "*.yml" 2>/dev/null | head -20

echo "=== ACCURATE CONFIG-PROD (DB section) ==="
echo kutul0nc4t | sudo -S find /progs -name "config-prod.properties" 2>/dev/null | while read f; do
  echo "--- $f ---"
  echo kutul0nc4t | sudo -S cat "$f" | grep -iE 'db\.|database|user|pass|jdbc|tenant|resource' | head -30
done

echo "=== .pgpass FILES ==="
echo kutul0nc4t | sudo -S find / -name ".pgpass" 2>/dev/null | head -5
echo kutul0nc4t | sudo -S cat /root/.pgpass 2>/dev/null | head -10
echo kutul0nc4t | sudo -S find /home -name ".pgpass" 2>/dev/null | head -5

echo "=== ACCURATE PROCESS ENV (db related) ==="
for pid in $(pgrep -f java); do
  echo "--- PID $pid ---"
  echo kutul0nc4t | sudo -S cat /proc/$pid/environ 2>/dev/null | tr '\0' '\n' | grep -iE 'db|database|pass|user|jdbc|resource|tenant' | head -20
done

echo "=== DONE ==="
REMOTECMD
