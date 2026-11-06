#!/bin/bash
export PATH="/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin"

echo "=== SSH TO NEO WITH SUDO ==="
/usr/bin/sshpass -p kutul0nc4t ssh -o StrictHostKeyChecking=no -o ConnectTimeout=10 user@10.13.16.196 bash << 'REMOTECMD'
export PATH="/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin"

PID=$(pgrep -f 'java.*neo')
echo "NEO Java PID: $PID"

echo "=== SUDO JCMD GC.heap_info ==="
echo kutul0nc4t | sudo -S jcmd $PID GC.heap_info 2>&1 | head -20

echo "=== SUDO: SEARCH PROC MEM FOR XND ==="
echo kutul0nc4t | sudo -S grep -ao 'xnd_production[a-zA-Z0-9_\-]*' /proc/$PID/mem 2>/dev/null | sort -u | head -100

echo "=== SUDO: SEARCH /progs/neo FOR XND ==="
echo kutul0nc4t | sudo -S grep -rl 'xnd_production' /progs/neo/ 2>/dev/null | head -20

echo "=== SUDO: NEO APP CONFIG FILES ==="
echo kutul0nc4t | sudo -S find /progs/neo -name "*.properties" -o -name "*.yml" -o -name "*.xml" -o -name "*.conf" 2>/dev/null | head -30

echo "=== SUDO: CHECK config-prod.properties ==="
echo kutul0nc4t | sudo -S cat /progs/neo/neo-app/config-prod.properties 2>/dev/null | grep -iE 'xnd|xendit|secret|api.key|callback' | head -20

echo "=== SUDO: CHECK application.properties/yml ==="
echo kutul0nc4t | sudo -S find /progs/neo -name "application*" -o -name "config-prod*" 2>/dev/null | while read f; do
  echo "--- $f ---"
  echo kutul0nc4t | sudo -S cat "$f" 2>/dev/null | grep -iE 'xnd|xendit|payment|secret|api.key' | head -10
done

echo "=== SUDO: JMAP HISTOGRAM (Xendit classes) ==="
echo kutul0nc4t | sudo -S jmap -histo:live $PID 2>&1 | grep -iE 'xendit|payment|xnd' | head -20

echo "=== SUDO: JCMD PROPS ==="
echo kutul0nc4t | sudo -S jcmd $PID VM.system_properties 2>&1 | grep -iE 'xnd|xendit|secret|api|payment' | head -20

echo "=== SUDO: JCMD FLAGS ==="
echo kutul0nc4t | sudo -S jcmd $PID VM.flags 2>&1 | head -10

echo "=== DONE ==="
REMOTECMD
