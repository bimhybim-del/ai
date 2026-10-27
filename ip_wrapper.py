#!/usr/bin/env python3
"""Complete ip replacement for DirtyAH6. Pure stdlib netlink."""
import fcntl, os, socket, struct, sys

NETLINK_ROUTE = 0
NETLINK_XFRM = 6
AF_INET6 = 10
RTM_NEWLINK = 16
RTM_SETLINK = 19
RTM_NEWADDR = 20
RTM_NEWROUTE = 24
RTM_NEWNEIGH = 28
NLM_F_REQUEST = 1
NLM_F_CREATE = 0x400
NLM_F_EXCL = 0x200
NLM_F_REPLACE = 0x100
NLM_F_ACK = 4
IFLA_IFNAME = 3
IFLA_MTU = 4
IFLA_ADDRESS = 1
IFLA_LINKINFO = 18
IFLA_INFO_KIND = 1
IFLA_INFO_DATA = 2
IFLA_NET_NS_PID = 19
IFA_ADDRESS = 1
IFA_LOCAL = 2
IFA_FLAGS = 8
NDA_DST = 1
NDA_LLADDR = 2
RTA_DST = 1
RTA_OIF = 4
RTA_PREFSRC = 7
RTA_TABLE = 15
RTA_ENCAP_TYPE = 21
RTA_ENCAP = 22
IFF_UP = 1
NUD_PERMANENT = 0x80
VETH_INFO_PEER = 1
XFRM_MSG_NEWSA = 16
XFRM_MSG_NEWPOLICY = 24
RT_TABLE_LOCAL = 255

def pad4(n): return (4 - n % 4) % 4
def nla(t, d):
    if isinstance(d, str): d = d.encode() + b'\x00'
    l = 4 + len(d); return struct.pack('HH', l, t) + d + b'\x00' * pad4(l)
def nested_nla(t, *a):
    p = b''.join(a); l = 4 + len(p); return struct.pack('HH', l, t) + p + b'\x00' * pad4(l)

def nl_do(proto, msg_type, flags, payload):
    s = socket.socket(socket.AF_NETLINK, socket.SOCK_RAW, proto); s.bind((0,0))
    hdr = struct.pack('IHHII', 16+len(payload), msg_type, flags|NLM_F_REQUEST|NLM_F_ACK, os.getpid(), 0)
    s.send(hdr + payload); r = s.recv(65536); s.close()
    return len(r) >= 20 and struct.unpack_from('i', r, 16)[0] == 0

def idx(name):
    try: return socket.if_nametoindex(name)
    except: return 0

def mac(dev):
    s = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
    info = fcntl.ioctl(s.fileno(), 0x8927, struct.pack('256s', dev.encode()[:15]))
    s.close(); return ':'.join('%02x' % b for b in info[18:24])

def do_link(a):
    if a[0] == 'add' and 'veth' in a:
        nm = a[1]; pi = a.index('name', 3)+1 if 'name' in a[3:] else -1; pr = a[pi] if pi>0 else 'v1'
        ii = struct.pack('BxHiII', 0,0,0,0,0)
        pii = struct.pack('BxHiII', 0,0,0,0,0) + nla(IFLA_IFNAME, pr)
        pnl = struct.pack('HH', 4+len(pii), VETH_INFO_PEER) + pii + b'\x00'*pad4(4+len(pii))
        at = nla(IFLA_IFNAME, nm) + nested_nla(IFLA_LINKINFO, nla(IFLA_INFO_KIND,'veth'), nested_nla(IFLA_INFO_DATA, pnl))
        return 0 if nl_do(0, RTM_NEWLINK, NLM_F_CREATE|NLM_F_EXCL, ii+at) else 1
    elif a[0] == 'set':
        d=a[1]; i=idx(d);
        if not i: return 1
        fl=0; ch=0; at=b''; j=2
        while j<len(a):
            if a[j]=='up': fl=IFF_UP; ch=IFF_UP
            elif a[j]=='down': ch=IFF_UP
            elif a[j]=='mtu': at+=nla(IFLA_MTU, struct.pack('I',int(a[j+1]))); j+=1
            elif a[j]=='netns': at+=nla(IFLA_NET_NS_PID, struct.pack('I',int(a[j+1]))); j+=1
            j+=1
        ii = struct.pack('BxHiII', 0,0,i,fl,ch)
        return 0 if nl_do(0, RTM_SETLINK, 0, ii+at) else 1

def do_addr(a, fam):
    if a[0]=='add':
        ap=a[1]; ad,pf=ap.split('/'); di=a.index('dev')+1; d=a[di]; i=idx(d)
        if not i: return 1
        f = socket.AF_INET6 if fam=='-6' else socket.AF_INET
        fl = 0x02 if 'nodad' in a else 0
        ab = socket.inet_pton(f, ad)
        ifa = struct.pack('BBBBi', f, int(pf), fl, 0, i)
        at = nla(IFA_ADDRESS, ab) + nla(IFA_LOCAL, ab)
        if fl: at += nla(IFA_FLAGS, struct.pack('I', fl))
        return 0 if nl_do(0, RTM_NEWADDR, NLM_F_CREATE|NLM_F_EXCL, ifa+at) else 1

def do_neigh(a, fam):
    if a[0] in ('replace','add'):
        dst=a[1]; li=a.index('lladdr')+1; ll=a[li]; di=a.index('dev')+1; d=a[di]; i=idx(d)
        if not i: return 1
        f = socket.AF_INET6 if fam=='-6' else socket.AF_INET
        ndm = struct.pack('BxHiHBB', f, 0, i, NUD_PERMANENT, 0, 0)
        ab = socket.inet_pton(f, dst)
        mb = bytes(int(x,16) for x in ll.split(':'))
        at = nla(NDA_DST, ab) + nla(NDA_LLADDR, mb)
        flags = NLM_F_CREATE | (NLM_F_REPLACE if a[0]=='replace' else NLM_F_EXCL)
        return 0 if nl_do(0, RTM_NEWNEIGH, flags, ndm+at) else 1

def do_route(a, fam):
    act = a[0]
    if act in ('replace','add'):
        is_local = 'local' in a
        j = 1
        if a[j] == 'local': j += 1
        dst = a[j]; j += 1
        f = socket.AF_INET6 if fam=='-6' else socket.AF_INET
        if '/' in dst:
            da, dp = dst.split('/')
        else:
            da = dst; dp = 128 if f==socket.AF_INET6 else 32
        rt_type = 2 if is_local else 1  # RTN_LOCAL=2, RTN_UNICAST=1
        tbl = RT_TABLE_LOCAL if 'local' in a and 'table' in a else 254
        if 'table' in a:
            ti = a.index('table')+1
            t = a[ti]
            tbl = RT_TABLE_LOCAL if t=='local' else int(t)
        rtm = struct.pack('BBBBBBBBi', f, int(dp), 0, 0, tbl if tbl<256 else 0, 4, 0, rt_type, 0)
        ab = socket.inet_pton(f, da)
        at = nla(RTA_DST, ab)
        # Skip encap (ioam6) — not critical for exploit
        ki = {x: a[a.index(x)+1] for x in ('dev','src') if x in a}
        if 'dev' in ki:
            i = idx(ki['dev'])
            if i: at += nla(RTA_OIF, struct.pack('i', i))
        if 'src' in ki:
            at += nla(RTA_PREFSRC, socket.inet_pton(f, ki['src']))
        if tbl >= 256:
            at += nla(RTA_TABLE, struct.pack('I', tbl))
        flags = NLM_F_CREATE | (NLM_F_REPLACE if act=='replace' else NLM_F_EXCL)
        return 0 if nl_do(0, RTM_NEWROUTE, flags, rtm+at) else 1

def do_xfrm(a):
    """ip xfrm state/policy add — use raw XFRM netlink"""
    if a[0] == 'state' and a[1] == 'add':
        return xfrm_state(a[2:])
    elif a[0] == 'policy' and a[1] == 'add':
        return xfrm_policy(a[2:])
    return 1

def xfrm_state(a):
    p = {}; i = 0
    while i < len(a):
        if a[i]=='src': p['src']=a[i+1]; i+=1
        elif a[i]=='dst': p['dst']=a[i+1]; i+=1
        elif a[i]=='proto': p['proto']=a[i+1]; i+=1
        elif a[i]=='spi': p['spi']=int(a[i+1],0); i+=1
        elif a[i]=='reqid': p['reqid']=int(a[i+1],0); i+=1
        elif a[i]=='mode': p['mode']=a[i+1]; i+=1
        elif a[i]=='auth-trunc': p['alg']=a[i+1].replace("'",""); p['key']=a[i+2]; p['trunc']=int(a[i+3]); i+=3
        i+=1
    proto_num = 51 if p.get('proto')=='ah' else 50
    mode_num = 0 if p.get('mode')=='transport' else 1
    # xfrm_usersa_info (224 bytes):
    # selector (56 bytes) - zeroed for wildcard
    sel = b'\x00' * 56
    # id: daddr(16) + spi(4) + proto(2) + pad(2) = 24
    sa_id = socket.inet_pton(AF_INET6, p['dst']) + struct.pack('!I', p['spi']) + struct.pack('H', proto_num) + b'\x00' * 2
    # saddr (16)
    saddr = socket.inet_pton(AF_INET6, p['src'])
    # lft_cfg (64) - all max
    lft = struct.pack('8Q', *([0xFFFFFFFFFFFFFFFF]*4 + [0]*4))
    # curlft (32) - zeros
    curlft = b'\x00' * 32
    # stats (12) - zeros
    stats = b'\x00' * 12
    # seq(4) + reqid(4)
    seq_reqid = struct.pack('II', 0, p['reqid'])
    # family(2) + mode(1) + replay(1) + flags(1) + pad(7) = 12
    tail = struct.pack('HBBBB', AF_INET6, mode_num, 0, 0, 0) + b'\x00' * 7
    sa = sel + sa_id + saddr + lft + curlft + stats + seq_reqid + tail
    # attrs: XFRMA_ALG_AUTH_TRUNC
    key_bytes = bytes.fromhex(p['key'].replace('0x',''))
    alg_name = p['alg'].replace("'","").encode().ljust(64, b'\x00')
    alg_data = alg_name + struct.pack('II', len(key_bytes)*8, p['trunc']) + key_bytes
    at = nla(6, alg_data)  # XFRMA_ALG_AUTH_TRUNC=6
    return 0 if nl_do(NETLINK_XFRM, XFRM_MSG_NEWSA, NLM_F_CREATE|NLM_F_EXCL, sa+at) else 1

def xfrm_policy(a):
    p = {}; i = 0
    while i < len(a):
        if a[i]=='dir': p['dir']=a[i+1]; i+=1
        elif a[i]=='src': p['src']=a[i+1]; i+=1
        elif a[i]=='dst': p['dst']=a[i+1]; i+=1
        elif a[i]=='proto': p['proto']=a[i+1]; i+=1
        elif a[i]=='reqid': p['reqid']=int(a[i+1],0); i+=1
        elif a[i]=='mode': p['mode']=a[i+1]; i+=1
        elif a[i]=='tmpl': pass  # tmpl args follow
        i+=1
    # tmpl src/dst extracted from after 'tmpl' keyword
    tmpl_i = a.index('tmpl') if 'tmpl' in a else -1
    t = {}
    if tmpl_i >= 0:
        j = tmpl_i + 1
        while j < len(a):
            if a[j]=='src': t['src']=a[j+1]; j+=1
            elif a[j]=='dst': t['dst']=a[j+1]; j+=1
            elif a[j]=='proto': t['proto']=a[j+1]; j+=1
            elif a[j]=='reqid': t['reqid']=int(a[j+1],0); j+=1
            elif a[j]=='mode': t['mode']=a[j+1]; j+=1
            j+=1
    # Build xfrm_userpolicy_info
    sa, sp = p.get('src','::').split('/'); da, dp = p.get('dst','::').split('/')
    # sel
    sel = socket.inet_pton(AF_INET6, da) + socket.inet_pton(AF_INET6, sa)
    sel += struct.pack('HHHHBBBBII', 0, 0, 0, 0, int(dp), int(sp), 0, 0, 0, 0)
    # lft
    lft = struct.pack('QQQQQQQQ', 0xFFFFFFFFFFFFFFFF, 0xFFFFFFFFFFFFFFFF, 0xFFFFFFFFFFFFFFFF, 0xFFFFFFFFFFFFFFFF, 0, 0, 0, 0)
    curlft = b'\x00' * 32
    # dir: out=1, in=0, fwd=2
    dirs = {'out': 1, 'in': 0, 'fwd': 2}
    pol = sel + lft + curlft
    pol += struct.pack('IBBBBIIII', 0, dirs.get(p.get('dir','out'), 1), 0, 0, 0, 0, 0, 0, 0)
    # tmpl attribute
    if t:
        tsrc = socket.inet_pton(AF_INET6, t.get('src','::'))
        tdst = socket.inet_pton(AF_INET6, t.get('dst','::'))
        tid = tdst + struct.pack('IH', 0, 51 if t.get('proto')=='ah' else 50) + b'\x00'*2
        tmpl = tid + tsrc
        tmpl += struct.pack('IBBBB', t.get('reqid', 0), 0 if t.get('mode')=='transport' else 1, 0, AF_INET6, 2)
        tmpl += b'\x00' * 4
        pol += nla(7, tmpl)  # XFRMA_TMPL=7
    return 0 if nl_do(NETLINK_XFRM, XFRM_MSG_NEWPOLICY, NLM_F_CREATE|NLM_F_EXCL, pol) else 1

def main():
    a = sys.argv[1:]
    if not a: return 1
    if a[0] == 'link': return do_link(a[1:])
    if a[0] in ('-6','-4'):
        f = a[0]
        if a[1] == 'addr': return do_addr(a[2:], f)
        if a[1] == 'neigh': return do_neigh(a[2:], f)
        if a[1] == 'route': return do_route(a[2:], f)
    if a[0] == 'xfrm': return do_xfrm(a[1:])
    if a[0] == '-o' and 'link' in a and 'show' in a:
        di = a.index('dev')+1; d = a[di]
        try: print(f"2: {d}: <> link/ether {mac(d)}"); return 0
        except: return 1
    # Fallback busybox
    import subprocess
    return subprocess.run(['/tmp/busybox','ip']+a).returncode

if __name__=='__main__': sys.exit(main() or 0)
# fixed xfrm 1793100950
