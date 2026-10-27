#!/usr/bin/env python3
"""Hybrid ip wrapper: Python netlink for veth, static binary for xfrm."""
import os, socket, struct, sys, fcntl, subprocess

AF_INET6 = 10
NETLINK_ROUTE = 0

def pad4(n): return (4 - n % 4) % 4
def nla(t, d):
    if isinstance(d, str): d = d.encode() + b'\x00'
    l = 4 + len(d); return struct.pack('HH', l, t) + d + b'\x00' * pad4(l)
def nested_nla(t, *a):
    p = b''.join(a); l = 4 + len(p); return struct.pack('HH', l, t) + p + b'\x00' * pad4(l)
def nl_do(proto, msg_type, flags, payload):
    s = socket.socket(socket.AF_NETLINK, socket.SOCK_RAW, proto); s.bind((0,0))
    hdr = struct.pack('IHHII', 16+len(payload), msg_type, flags|1|4, os.getpid(), 0)
    s.send(hdr + payload); r = s.recv(65536); s.close()
    return len(r) >= 20 and struct.unpack_from('i', r, 16)[0] == 0
def idx(name):
    try: return socket.if_nametoindex(name)
    except: return 0
def mac(dev):
    s = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
    info = fcntl.ioctl(s.fileno(), 0x8927, struct.pack('256s', dev.encode()[:15]))
    s.close(); return ':'.join('%02x' % b for b in info[18:24])

args = sys.argv[1:]
if not args: sys.exit(1)

# VETH CREATION: Python netlink (PROVEN)
if args[0] == 'link' and len(args) > 1:
    if args[1] == 'add' and 'veth' in args:
        nm = args[2]; pi = args.index('name', 3)+1 if 'name' in args[3:] else -1
        pr = args[pi] if pi > 0 else args[args.index('peer')+1] if 'peer' in args else 'v1'
        ii = struct.pack('BxHiII', 0,0,0,0,0)
        pii = struct.pack('BxHiII', 0,0,0,0,0) + nla(3, pr)
        pnl = struct.pack('HH', 4+len(pii), 1) + pii + b'\x00'*pad4(4+len(pii))
        at = nla(3, nm) + nested_nla(18, nla(1,'veth'), nested_nla(2, pnl))
        sys.exit(0 if nl_do(0, 16, 0x400|0x200, ii+at) else 1)
    elif args[1] == 'set':
        d=args[2]; i=idx(d)
        if not i: sys.exit(1)
        fl=0; ch=0; at=b''; j=3
        while j<len(args):
            if args[j]=='up': fl=1; ch=1
            elif args[j]=='down': ch=1
            elif args[j]=='mtu': at+=nla(4, struct.pack('I',int(args[j+1]))); j+=1
            elif args[j]=='netns': at+=nla(19, struct.pack('I',int(args[j+1]))); j+=1
            j+=1
        ii = struct.pack('BxHiII', 0,0,i,fl,ch)
        sys.exit(0 if nl_do(0, 19, 0, ii+at) else 1)

# IP -o link show: get MAC
if args[0] == '-o' and 'link' in args and 'show' in args:
    di = args.index('dev')+1; d = args[di]
    try: print(f"2: {d}: <> link/ether {mac(d)}"); sys.exit(0)
    except: sys.exit(1)

# IP -6 addr add: Python netlink
if args[0] in ('-6','-4') and len(args)>2 and args[1] == 'addr' and args[2] == 'add':
    ap=args[3]; ad,pf=ap.split('/'); di=args.index('dev')+1; d=args[di]; i=idx(d)
    if not i: sys.exit(1)
    f = socket.AF_INET6 if args[0]=='-6' else socket.AF_INET
    fl = 0x02 if 'nodad' in args else 0
    ab = socket.inet_pton(f, ad)
    ifa = struct.pack('BBBBi', f, int(pf), fl, 0, i)
    at = nla(1, ab) + nla(2, ab)
    if fl: at += nla(8, struct.pack('I', fl))
    sys.exit(0 if nl_do(0, 20, 0x400|0x200, ifa+at) else 1)

# EVERYTHING ELSE: delegate to static Alpine ip binary
# This handles: xfrm state/policy, neigh, route, etc.
static_ip = '/tmp/ip_static_bin'
if os.path.exists(static_ip):
    sys.exit(subprocess.call([static_ip] + args))
else:
    # Fallback to busybox
    sys.exit(subprocess.call(['/tmp/busybox', 'ip'] + args))
