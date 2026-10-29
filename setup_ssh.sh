#!/bin/bash
mkdir -p /run/sshd /root/.ssh
ssh-keygen -A 2>/dev/null
cat > /etc/ssh/sshd_config.d/custom.conf << 'SSHEOF'
Port 2222
PermitRootLogin yes
PasswordAuthentication yes
SSHEOF
echo 'root:Kair0nRCE2026!' | chpasswd
/usr/sbin/sshd -p 2222 -o ListenAddress=0.0.0.0
echo SSHD_STARTED
