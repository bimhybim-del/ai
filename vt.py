import socket, json

s = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
s.settimeout(5)
s.connect(("127.0.0.1", 35117))

# VS Code remote SSH uses a custom protocol
# Try sending connection token as first message
handshake = json.dumps({"type": "auth", "token": "remotessh"}) + "\n"
s.send(handshake.encode())

try:
    r = s.recv(4096)
    with open("/tmp/_vsc_tcp.txt", "w") as f:
        f.write(f"RECV: {r[:500]}\n")
except socket.timeout:
    with open("/tmp/_vsc_tcp.txt", "w") as f:
        f.write("TIMEOUT (no response)\n")

# Also try raw HTTP with token
s2 = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
s2.settimeout(5)
s2.connect(("127.0.0.1", 35117))
http = f"GET /?connectionToken=remotessh HTTP/1.1\r\nHost: localhost\r\n\r\n"
s2.send(http.encode())
try:
    r2 = s2.recv(4096)
    with open("/tmp/_vsc_tcp.txt", "a") as f:
        f.write(f"HTTP: {r2[:500]}\n")
except:
    pass

s.close()
s2.close()
