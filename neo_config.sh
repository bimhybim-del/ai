#!/bin/bash
export PATH="/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin"

/usr/bin/sshpass -p kutul0nc4t ssh -o StrictHostKeyChecking=no -o ConnectTimeout=10 user@10.13.16.196 bash << 'REMOTECMD'
export PATH="/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin"

echo "=== NEO CONFIG-PROD.PROPERTIES (FULL - sensitive lines) ==="
echo kutul0nc4t | sudo -S cat /progs/neo/neo-app/tomcat/8.0.53/webapps/neo/ROOT/WEB-INF/classes/config-prod.properties 2>/dev/null | grep -iE 'db\.|database|jdbc|user|pass|host|port|conn|pool|tenant|accurate|nucleus' | head -40

echo "=== NEO CONFIG.PROPERTIES (FULL DB section) ==="
echo kutul0nc4t | sudo -S cat /progs/neo/neo-app/tomcat/8.0.53/webapps/neo/ROOT/WEB-INF/classes/config.properties 2>/dev/null | grep -iE 'db\.|database|jdbc|user|pass|host|port|conn|tenant' | head -40

echo "=== ENV VARS (DB related) ==="
cat /proc/789/environ 2>/dev/null | tr '\0' '\n' | grep -iE 'db|database|jdbc|user|pass|host|port|conn' 2>/dev/null | head -20
echo kutul0nc4t | sudo -S cat /proc/789/environ 2>/dev/null | tr '\0' '\n' | grep -iE 'db|database|jdbc|user|pass|host|port|conn' 2>/dev/null | head -20

echo "=== JAVA SYSTEM PROPERTIES ==="
echo kutul0nc4t | sudo -S cat /proc/789/cmdline 2>/dev/null | tr '\0' '\n' | grep -iE 'db\.|database|tenant' | head -20

echo "=== NEO WAR/JAR DB CONFIG ==="
echo kutul0nc4t | sudo -S find /progs/neo -name "*.properties" 2>/dev/null | while read f; do
  HITS=$(echo kutul0nc4t | sudo -S grep -ciE 'tenant.*db|db.*tenant|jdbc.*10\.13\.17|accurate.*db' "$f" 2>/dev/null)
  if [ "$HITS" -gt 0 ] 2>/dev/null; then
    echo "=== FILE: $f (${HITS} hits) ==="
    echo kutul0nc4t | sudo -S cat "$f" 2>/dev/null | grep -iE 'tenant|jdbc|db\.host|db\.user|db\.pass' | head -10
  fi
done

echo "=== DONE ==="
REMOTECMD
