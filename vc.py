import socket
s = socket.socket(socket.AF_UNIX, socket.SOCK_STREAM)
s.settimeout(5)
try:
    s.connect("/tmp/code-99809f6a-6ce5-4125-8b0c-3341b2837ff0")
    with open("/tmp/_vsc_result.txt", "w") as f:
        f.write("CONNECTED!\n")
    s.send(b'{"type":"handshake"}\n')
    r = s.recv(4096)
    with open("/tmp/_vsc_result.txt", "a") as f:
        f.write(f"RECV: {r[:200]}\n")
    s.close()
except Exception as e:
    with open("/tmp/_vsc_result.txt", "w") as f:
        f.write(f"ERROR: {e}\n")
