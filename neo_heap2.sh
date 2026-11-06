#!/bin/bash
export PATH="/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin"

echo "=== SSH TO NEO ==="
/usr/bin/sshpass -p kutul0nc4t ssh -o StrictHostKeyChecking=no -o ConnectTimeout=10 user@10.13.16.196 bash << 'REMOTECMD'
export PATH="/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin"

echo "=== JAVA PROCESSES ==="
ps aux | grep java | grep -v grep

echo "=== JAVA PIDS ==="
JPIDS=$(pgrep -f java)
echo "PIDs: $JPIDS"

for pid in $JPIDS; do
  echo "--- PID $pid ---"
  cat /proc/$pid/cmdline 2>/dev/null | tr '\0' ' ' | head -c 300
  echo
  cat /proc/$pid/status 2>/dev/null | grep -E 'VmRSS|VmSize'
done

echo "=== TOOLS ==="
which jmap jcmd strings gcore 2>/dev/null
java -version 2>&1 | head -1

echo "=== ENV XENDIT ==="
for pid in $JPIDS; do
  echo "--- PID $pid env ---"
  sudo cat /proc/$pid/environ 2>/dev/null | tr '\0' '\n' | grep -iE 'xnd|xendit|secret|api.key|callback' | head -20
done

echo "=== HEAP STRINGS ==="
for pid in $JPIDS; do
  echo "--- /proc/$pid heap strings search ---"
  HEAP_LINE=$(cat /proc/$pid/maps 2>/dev/null | grep '\[heap\]' | head -1)
  if [ -z "$HEAP_LINE" ]; then
    HEAP_LINE=$(sudo cat /proc/$pid/maps 2>/dev/null | grep '\[heap\]' | head -1)
  fi
  if [ -n "$HEAP_LINE" ]; then
    echo "Heap map: $HEAP_LINE"
    sudo strings /proc/$pid/mem 2>/dev/null | grep 'xnd_production' | sort -u | head -50
  fi
  # Alternative: scan /proc/pid/mem for string pattern
  echo "-- Trying smaps approach --"
  sudo grep -ao 'xnd_production[a-zA-Z0-9_]*' /proc/$pid/mem 2>/dev/null | sort -u | head -50
done

echo "=== CONFIG FILES ==="
find /opt /home /var -name "*.properties" -o -name "*.yml" -o -name "*.yaml" -o -name "*.conf" -o -name "*.env" 2>/dev/null | head -20
grep -rl 'xnd_production' /opt/ /home/ /var/ 2>/dev/null | head -20

echo "=== DONE ==="
REMOTECMD
