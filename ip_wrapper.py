#!/usr/bin/env python3
"""Pure-Python ip replacement using raw netlink. No external deps."""
import ctypes, os, socket, struct, sys

# Netlink constants
NETLINK_ROUTE = 0
RTM_NEWLINK = 16
RTM_SETLINK = 19  
RTM_NEWADDR = 20
RTM_NEWNEIGH = 28
RTM_NEWROUTE = 24
NLM_F_REQUEST = 1
NLM_F_CREATE = 0x400
NLM_F_EXCL = 0x200
NLM_F_ACK = 4
NLM_F_REPLACE = 0x100

IFLA_IFNAME = 3
IFLA_MTU = 4
IFLA_LINK = 5
IFLA_ADDRESS = 1
IFLA_LINKINFO = 18
IFLA_INFO_KIND = 1
IFLA_INFO_DATA = 2
IFLA_NET_NS_PID = 19
VETH_INFO_PEER = 1
IFA_ADDRESS = 1
IFA_LOCAL = 2
IFA_FLAGS = 8
IFF_UP = 1

def pad4(n):
    return (4 - n % 4) % 4

def nlattr(typ, data):
    if isinstance(data, str): data = data.encode() + b'\x00'
    l = 4 + len(data)
    return struct.pack('HH', l, typ) + data + b'\x00' * pad4(l)

def nested(typ, *attrs):
    payload = b''.join(attrs)
    l = 4 + len(payload)
    return struct.pack('HH', l, typ) + payload + b'\x00' * pad4(l)

def nl_send(sock, msg_type, flags, payload):
    hdr = struct.pack('IHHII', 16 + len(payload), msg_type, flags | NLM_F_REQUEST | NLM_F_ACK, os.getpid(), 0)
    sock.send(hdr + payload)
    resp = sock.recv(4096)
    if len(resp) >= 20:
        err = struct.unpack_from('i', resp, 16)[0]
        return err == 0
    return False

def if_nametoindex(name):
    try:
        return socket.if_nametoindex(name)
    except:
        return 0

def link_add_veth(name, peer):
    sock = socket.socket(socket.AF_NETLINK, socket.SOCK_RAW, NETLINK_ROUTE)
    sock.bind((0, 0))
    ifinfo = struct.pack('BxHiII', 0, 0, 0, 0, 0)
    peer_ifinfo = struct.pack('BxHiII', 0, 0, 0, 0, 0)
    peer_attrs = nlattr(IFLA_IFNAME, peer)
    peer_msg = peer_ifinfo + peer_attrs
    peer_nl = struct.pack('HH', 4 + len(peer_msg), VETH_INFO_PEER) + peer_msg + b'\x00' * pad4(4 + len(peer_msg))
    attrs = nlattr(IFLA_IFNAME, name)
    attrs += nested(IFLA_LINKINFO, nlattr(IFLA_INFO_KIND, 'veth'), nested(IFLA_INFO_DATA, peer_nl))
    ok = nl_send(sock, RTM_NEWLINK, NLM_F_CREATE | NLM_F_EXCL, ifinfo + attrs)
    sock.close()
    return ok

def link_set(dev, **kwargs):
    sock = socket.socket(socket.AF_NETLINK, socket.SOCK_RAW, NETLINK_ROUTE)
    sock.bind((0, 0))
    idx = if_nametoindex(dev)
    if not idx: return False
    flags = 0
    change = 0
    if kwargs.get('state') == 'up':
        flags = IFF_UP
        change = IFF_UP
    ifinfo = struct.pack('BxHiII', 0, 0, idx, flags, change)
    attrs = b''
    if 'mtu' in kwargs:
        attrs += nlattr(IFLA_MTU, struct.pack('I', kwargs['mtu']))
    if 'net_ns_pid' in kwargs:
        attrs += nlattr(IFLA_NET_NS_PID, struct.pack('I', kwargs['net_ns_pid']))
    ok = nl_send(sock, RTM_SETLINK, 0, ifinfo + attrs)
    sock.close()
    return ok

def addr_add(dev, addr, prefix, family=socket.AF_INET6, flags=0):
    sock = socket.socket(socket.AF_NETLINK, socket.SOCK_RAW, NETLINK_ROUTE)
    sock.bind((0, 0))
    idx = if_nametoindex(dev)
    if not idx: return False
    ifa = struct.pack('BBBBi', family, int(prefix), flags, 0, idx)
    addr_bytes = socket.inet_pton(family, addr)
    attrs = nlattr(IFA_ADDRESS, addr_bytes) + nlattr(IFA_LOCAL, addr_bytes)
    if flags:
        attrs += nlattr(IFA_FLAGS, struct.pack('I', flags))
    ok = nl_send(sock, RTM_NEWADDR, NLM_F_CREATE | NLM_F_EXCL, ifa + attrs)
    sock.close()
    return ok

def get_mac(dev):
    """Get MAC address of interface."""
    s = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
    import fcntl
    info = fcntl.ioctl(s.fileno(), 0x8927, struct.pack('256s', dev.encode()[:15]))
    mac = ':'.join('%02x' % b for b in info[18:24])
    s.close()
    return mac

def main():
    args = sys.argv[1:]
    if not args:
        return 1
    
    # Handle: ip link ...
    if args[0] == 'link':
        a = args[1:]
        if a[0] == 'add' and 'veth' in a:
            name = a[1]
            peer_idx = a.index('name', 3) + 1 if 'name' in a[3:] else -1
            peer = a[peer_idx] if peer_idx > 0 else 'veth1'
            return 0 if link_add_veth(name, peer) else 1
        elif a[0] == 'set':
            dev = a[1]
            kw = {}
            i = 2
            while i < len(a):
                if a[i] == 'up': kw['state'] = 'up'
                elif a[i] == 'down': kw['state'] = 'down'
                elif a[i] == 'mtu': kw['mtu'] = int(a[i+1]); i += 1
                elif a[i] == 'netns': kw['net_ns_pid'] = int(a[i+1]); i += 1
                i += 1
            return 0 if link_set(dev, **kw) else 1
    
    # Handle: ip -6 addr add ADDR/PREFIX dev DEV nodad
    if args[0] in ('-6', '-4'):
        fam = socket.AF_INET6 if args[0] == '-6' else socket.AF_INET
        if args[1] == 'addr' and args[2] == 'add':
            addr_pfx = args[3]
            addr, pfx = addr_pfx.split('/')
            dev_i = args.index('dev') + 1
            dev = args[dev_i]
            flags = 0x02 if 'nodad' in args else 0  # IFA_F_NODAD
            return 0 if addr_add(dev, addr, pfx, fam, flags) else 1
        elif args[1] == 'neigh':
            # ip -6 neigh replace ADDR lladdr MAC dev DEV nud permanent
            # Use busybox fallback
            pass
        elif args[1] == 'route':
            # Complex — use busybox fallback
            pass
    
    # Handle: ip -o link show dev XXX (get MAC)
    if args[0] == '-o' and args[1] == 'link' and args[2] == 'show':
        dev_i = args.index('dev') + 1
        dev = args[dev_i]
        try:
            mac = get_mac(dev)
            print(f"2: {dev}: <BROADCAST,MULTICAST,UP> link/ether {mac}")
            return 0
        except:
            return 1
    
    # Handle: ip xfrm — delegate to busybox
    if args[0] == 'xfrm':
        import subprocess
        return subprocess.run(['/tmp/busybox', 'ip'] + args).returncode
    
    # Fallback: busybox
    import subprocess
    return subprocess.run(['/tmp/busybox', 'ip'] + args).returncode

if __name__ == '__main__':
    sys.exit(main() or 0)
