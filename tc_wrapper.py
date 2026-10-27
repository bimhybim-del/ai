#!/usr/bin/env python3
"""Pure-Python tc netem replacement using netlink. No deps."""
import os, socket, struct, sys

NETLINK_ROUTE = 0
RTM_NEWQDISC = 36
NLM_F_REQUEST = 1
NLM_F_CREATE = 0x400
NLM_F_REPLACE = 0x100
NLM_F_ACK = 4
TCA_KIND = 1
TCA_OPTIONS = 2
TC_H_ROOT = 0xFFFFFFFF

def pad4(n): return (4 - n % 4) % 4
def nla(t, d):
    if isinstance(d, str): d = d.encode() + b'\x00'
    l = 4 + len(d); return struct.pack('HH', l, t) + d + b'\x00' * pad4(l)

def nl_do(msg_type, flags, payload):
    s = socket.socket(socket.AF_NETLINK, socket.SOCK_RAW, NETLINK_ROUTE); s.bind((0,0))
    hdr = struct.pack('IHHII', 16+len(payload), msg_type, flags|NLM_F_REQUEST|NLM_F_ACK, os.getpid(), 0)
    s.send(hdr + payload); r = s.recv(65536); s.close()
    return len(r) >= 20 and struct.unpack_from('i', r, 16)[0] == 0

def idx(name):
    try: return socket.if_nametoindex(name)
    except: return 0

def main():
    a = sys.argv[1:]
    if not a or a[0] != 'qdisc': 
        import subprocess
        return subprocess.run(['/tmp/busybox', 'tc'] + a).returncode
    
    # tc qdisc replace/add dev DEV root netem limit LIMIT delay Nms
    act = a[1]  # replace/add
    di = a.index('dev') + 1; dev = a[di]; i = idx(dev)
    if not i: return 1
    
    limit = 1000; delay_us = 0
    for j, x in enumerate(a):
        if x == 'limit': limit = int(a[j+1])
        if x == 'delay':
            d = a[j+1]
            if d.endswith('ms'): delay_us = int(d[:-2]) * 1000
            elif d.endswith('us'): delay_us = int(d[:-2])
            else: delay_us = int(d) * 1000
    
    # tcmsg
    tcm = struct.pack('BBHiII', 0, 0, 0, i, TC_H_ROOT, 0x00010000)  # parent=root, handle=1:0
    # netem opts: struct tc_netem_qopt (24 bytes)
    # latency(us), limit, loss, gap, duplicate, jitter
    netem_opts = struct.pack('IIIIII', delay_us, limit, 0, 0, 0, 0)
    at = nla(TCA_KIND, 'netem') + nla(TCA_OPTIONS, netem_opts)
    
    flags = NLM_F_CREATE | (NLM_F_REPLACE if act == 'replace' else 0)
    return 0 if nl_do(RTM_NEWQDISC, flags, tcm + at) else 1

if __name__ == '__main__': sys.exit(main() or 0)
