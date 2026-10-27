#!/usr/bin/env python3
"""Minimal 'ip' replacement using ctypes/netlink for DirtyAH6 exploit."""
import ctypes, ctypes.util, os, socket, struct, subprocess, sys

# Most ip commands: delegate to busybox
# Only override: ip link add ... type veth
args = sys.argv[1:]

if len(args) >= 4 and args[0] == 'link' and args[1] == 'add' and 'veth' in args:
    # ip link add NAME type veth peer name PEER
    # Use netlink RTM_NEWLINK
    import struct
    
    name_idx = 2  # args[2] = device name
    peer_idx = args.index('name', 4) + 1 if 'name' in args[4:] else -1
    dev_name = args[name_idx].encode() + b'\x00'
    peer_name = args[peer_idx].encode() + b'\x00' if peer_idx > 0 else b'veth1\x00'
    
    NETLINK_ROUTE = 0
    RTM_NEWLINK = 16
    NLM_F_REQUEST = 1
    NLM_F_CREATE = 0x400
    NLM_F_EXCL = 0x200
    NLM_F_ACK = 4
    IFLA_IFNAME = 3
    IFLA_LINKINFO = 18
    IFLA_INFO_KIND = 1
    IFLA_INFO_DATA = 2
    VETH_INFO_PEER = 1
    
    sock = socket.socket(socket.AF_NETLINK, socket.SOCK_RAW, NETLINK_ROUTE)
    sock.bind((0, 0))
    
    def nlattr(type_val, data):
        if isinstance(data, str): data = data.encode() + b'\x00'
        l = 4 + len(data)
        pad = (4 - l % 4) % 4
        return struct.pack('HH', l, type_val) + data + b'\x00' * pad
    
    def nested(type_val, *attrs):
        payload = b''.join(attrs)
        l = 4 + len(payload)
        pad = (4 - l % 4) % 4
        return struct.pack('HH', l, type_val) + payload + b'\x00' * pad
    
    # Build ifinfomsg
    ifinfo = struct.pack('BxHiII', 0, 0, 0, 0, 0)  # AF_UNSPEC, pad, ifindex=0, flags, change
    
    # Peer info (nested in VETH_INFO_PEER)
    peer_ifinfo = struct.pack('BxHiII', 0, 0, 0, 0, 0)
    peer_attrs = nlattr(IFLA_IFNAME, peer_name)
    peer_msg = peer_ifinfo + peer_attrs
    peer_len = 4 + len(peer_msg)
    peer_pad = (4 - peer_len % 4) % 4
    veth_peer = struct.pack('HH', peer_len, VETH_INFO_PEER) + peer_msg + b'\x00' * peer_pad
    
    attrs = nlattr(IFLA_IFNAME, dev_name)
    attrs += nested(IFLA_LINKINFO,
        nlattr(IFLA_INFO_KIND, 'veth'),
        nested(IFLA_INFO_DATA, veth_peer)
    )
    
    payload = ifinfo + attrs
    hdr = struct.pack('IHHII', 16 + len(payload), RTM_NEWLINK, NLM_F_REQUEST|NLM_F_CREATE|NLM_F_EXCL|NLM_F_ACK, 1, 0)
    
    sock.send(hdr + payload)
    resp = sock.recv(4096)
    # Check response
    err_code = struct.unpack_from('i', resp, 16)[0] if len(resp) >= 20 else -1
    if err_code == 0:
        sys.exit(0)
    else:
        print(f"netlink error: {err_code}", file=sys.stderr)
        sys.exit(1)

elif len(args) >= 2 and args[0] == 'xfrm':
    # xfrm commands need full iproute2 — try busybox first, fallback to python
    result = subprocess.run(['/tmp/busybox', 'ip'] + args, capture_output=True)
    if result.returncode != 0 and b"not found" in result.stderr:
        # Need to implement xfrm via netlink — complex
        # For now, try pyroute2 if installed
        try:
            from pyroute2 import IPRoute
            # TODO: implement xfrm commands
            pass
        except ImportError:
            print(f"ip {' '.join(args)}: not supported in wrapper", file=sys.stderr)
            sys.exit(1)
    sys.stdout.buffer.write(result.stdout)
    sys.stderr.buffer.write(result.stderr)
    sys.exit(result.returncode)

else:
    # Delegate to busybox ip
    result = subprocess.run(['/tmp/busybox', 'ip'] + args, capture_output=False)
    sys.exit(result.returncode)
