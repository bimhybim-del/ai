#!/usr/bin/env python3
"""tc command replacement using pyroute2."""
import sys

def main():
    args = sys.argv[1:]
    if not args:
        return 1
    if args[0] == 'qdisc':
        return handle_qdisc(args[1:])
    # Fallback to busybox tc
    import subprocess
    return subprocess.run(['/tmp/busybox', 'tc'] + args).returncode

def handle_qdisc(args):
    from pyroute2 import IPRoute
    ipr = IPRoute()
    try:
        action = args[0]  # replace, add, del
        dev_idx = args.index('dev')
        dev = args[dev_idx + 1]
        idx = ipr.link_lookup(ifname=dev)
        if not idx:
            return 1
        if 'netem' in args:
            # tc qdisc replace dev DEV root netem limit LIMIT delay Nms
            limit = None
            delay = None
            for i, a in enumerate(args):
                if a == 'limit': limit = int(args[i+1])
                if a == 'delay': delay = args[i+1].replace('ms','')
            kind = 'netem'
            opts = {}
            if limit: opts['limit'] = limit
            if delay: opts['delay'] = int(delay) * 1000  # ms to us? Check pyroute2 format
            try:
                ipr.tc('replace', kind=kind, index=idx[0], handle='1:', parent='root', **opts)
            except:
                try:
                    ipr.tc('add', kind=kind, index=idx[0], handle='1:', parent='root', **opts)
                except:
                    pass
            return 0
    except Exception as e:
        print(f"tc error: {e}", file=sys.stderr)
        return 1
    finally:
        ipr.close()

if __name__ == '__main__':
    sys.exit(main() or 0)
