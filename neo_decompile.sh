#!/bin/bash
export PATH="/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin"

/usr/bin/sshpass -p kutul0nc4t ssh -o StrictHostKeyChecking=no -o ConnectTimeout=10 user@10.13.16.196 bash << 'REMOTECMD'
export PATH="/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin"

echo "=== DECOMPILE XENDIT CLASS FILES ==="
# Use javap to decompile Xendit-related classes
NEOBASE="/progs/neo/neo-app/tomcat/8.0.53/webapps/neo/ROOT/WEB-INF/classes"

echo "--- XenditLinkPaymentPaymentRepo ---"
echo kutul0nc4t | sudo -S javap -c -p "$NEOBASE/com/cpssoft/web/neo/repo/XenditLinkPaymentPaymentRepo.class" 2>&1 | head -80

echo "--- XenditQrisPaymentRepo ---"
echo kutul0nc4t | sudo -S javap -c -p "$NEOBASE/com/cpssoft/web/neo/repo/XenditQrisPaymentRepo.class" 2>&1 | head -80

echo "=== STRINGS IN XENDIT JARS ==="
# Search all JARs in WEB-INF/lib for xnd_production
echo kutul0nc4t | sudo -S find "$NEOBASE/../lib" -name "*.jar" -exec sh -c 'strings "$1" | grep -l xnd_production 2>/dev/null && echo "FOUND IN: $1"' _ {} \; 2>/dev/null | head -20

# Also search for xendit in jar names
echo kutul0nc4t | sudo -S ls "$NEOBASE/../lib/" 2>/dev/null | grep -i xendit | head -10

echo "=== SEARCH ALL XENDIT IN ALL JAR ==="
for jar in $(echo kutul0nc4t | sudo -S find "$NEOBASE/../lib" -name "*.jar" 2>/dev/null); do
  HITS=$(echo kutul0nc4t | sudo -S unzip -p "$jar" 2>/dev/null | strings | grep -c 'xnd_production' 2>/dev/null)
  if [ "$HITS" -gt 0 ] 2>/dev/null; then
    echo "FOUND $HITS hits in: $jar"
    echo kutul0nc4t | sudo -S unzip -p "$jar" 2>/dev/null | strings | grep 'xnd_production' | sort -u | head -10
  fi
done

echo "=== ALL CONFIG FILES WITH XENDIT ==="
echo kutul0nc4t | sudo -S grep -rl 'xendit\|xnd_production\|xnd_public' /progs/neo/ --include="*.properties" --include="*.yml" --include="*.yaml" --include="*.xml" --include="*.json" 2>/dev/null | head -20

echo "=== config.properties (non-prod) ==="
echo kutul0nc4t | sudo -S cat "$NEOBASE/config.properties" 2>/dev/null | grep -iE 'xnd|xendit|payment\..*key|callback' | head -20

echo "=== config-stage.properties ==="
echo kutul0nc4t | sudo -S cat "$NEOBASE/config-stage.properties" 2>/dev/null | grep -iE 'xnd|xendit|payment\..*key|callback' | head -20

echo "=== WEB-INF XML configs ==="
echo kutul0nc4t | sudo -S grep -rl 'xendit\|xnd_' "$NEOBASE/../" --include="*.xml" 2>/dev/null | head -10

echo "=== DONE ==="
REMOTECMD
