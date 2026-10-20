# Container Escape 0-Day Research — Kernel 6.8.0-90-generic

## Target Environment

- **Kernel**: `6.8.0-90-generic` (Ubuntu 24.04 Noble, built Nov 18 2025)
- **Container**: Docker (containerd), Alpine Linux 3.23.4
- **User**: `postgres` (uid=70) — NOT root
- **CapEff**: `0x0000000000000000` (ZERO effective capabilities)
- **CapBnd**: `0x00000000a80425fb` (CAP_NET_RAW, CAP_SETUID, CAP_SETGID present in bounding set)
- **Seccomp**: mode 2 (filter), Docker default profile
- **AppArmor**: `docker-default (enforce)`
- **CPU**: 48 cores (AMD), SLUB order-1 for skbuff_head_cache
- **RAM**: 377 GB
- **BTF**: `/sys/kernel/btf/vmlinux` readable (6MB, full BTF data)
- **Uptime**: 287+ days (kernel never rebooted → KASLR fixed since boot)

## The Problem

We have **RCE inside a PostgreSQL container** on this host. Goal is **container-to-host escape** to get root on the bare-metal host. We have tested **7 different CVEs** — ALL blocked by Docker's default seccomp profile.

## Syscall Availability Map

### ALLOWED by seccomp ✅
```
socket(AF_UNIX)          — Unix domain sockets
socket(AF_INET/AF_INET6) — TCP/UDP
socket(AF_ALG)           — Kernel crypto API
socket(AF_NETLINK)       — Netlink (incl NETLINK_XFRM)
socket(SCTP)             — SCTP protocol
sendmsg / recvmsg        — Message passing with SCM_RIGHTS
splice                   — Zero-copy pipe transfer
fork / clone (threads)   — Process creation
mmap / mprotect          — Memory mapping
ptrace(TRACEME)          — Self-trace
memfd_create             — Anonymous file creation
setxattr / fsetxattr     — Extended attributes
msgsnd / msgrcv          — System V message queues
pipe / pipe2             — Pipe creation
epoll / poll / select    — I/O multiplexing
prctl                    — Process control
sched_setaffinity        — CPU affinity (but fails with EINVAL on high CPU#)
```

### BLOCKED by seccomp ❌
```
socket(AF_PACKET)        — Raw packet sockets (CRITICAL — all public exploits need this)
add_key / keyctl / request_key — Kernel keyring management
unshare(CLONE_NEWUSER)   — User namespace creation
io_uring_setup           — io_uring
userfaultfd              — User fault handling
mount / umount           — Filesystem mounting
perf_event_open          — Performance monitoring
init_module / finit_module — Module loading
```

### ALLOWED but PERMISSION DENIED (need capabilities) ⚠️
```
XFRM_MSG_NEWSA via NETLINK_XFRM — needs CAP_NET_ADMIN
/sys/kernel/slab/*/order         — needs root (file mode -r--------)
/proc/sysrq-trigger              — needs root
```

## Kernel Modules Already Loaded

These modules are LIVE in the host kernel (confirmed via /proc/modules):
```
sctp           495616  46   — SCTP protocol (actively used by trading bots)
rxrpc          438272   0   — RxRPC (loaded by our DirtyFrag test)
fcrypt          20480   1   — fcrypt cipher (loaded by our DirtyFrag test)
pcbc            12288   1   — PCBC mode (loaded by our DirtyFrag test)
algif_skcipher  12288   0   — AF_ALG skcipher interface
af_alg          32768   1   — AF_ALG framework
xfrm_user       61440   1   — XFRM/IPsec user interface
xfrm_algo       16384   1   — XFRM algorithms
nf_tables      376832 1265  — nftables (heavily used)
overlay        212992  24   — OverlayFS (Docker)
wireguard      114688   0   — WireGuard VPN
bridge         421888   0   — Network bridge (Docker)
```

**NOT loaded (and cannot be auto-loaded from container):**
```
algif_aead     — AF_ALG AEAD interface (needed by Copy Fail CVE-2026-31431)
esp4 / esp6    — ESP transform (needed by DirtyFrag ESP variant)
```

## CVEs Tested and Results

### 1. CVE-2026-31431 — Copy Fail (algif_aead page-cache write)
- **Status**: FAILED
- **Why**: `algif_aead` module not loaded. AF_ALG socket creation works, bind("aead", "authencesn(...)") returns ENOENT.
- **What works**: `socket(AF_ALG)` ✅, `bind("skcipher", "cbc(aes)")` ✅, `splice()` ✅
- **Blocker**: Kernel `request_module("algif-aead")` blocked — module auto-loading does not trigger from container
- **Key insight**: If algif_aead module could be loaded by ANY means, the full exploit chain would work. splice() and sendmsg() are allowed.
- **Source**: `t1ckprivate/CVE-2026-31431-Copy-Fail` (pre-compiled musl binary, tested)

### 2. CVE-2026-43284 — DirtyFrag RxRPC variant
- **Status**: PARTIAL SUCCESS then FAILED
- **What works**: rxrpc module AUTO-LOADED successfully! fcrypt selftest OK! Key generation stages 1a/1b/1c all pass!
- **Blocker**: `add_key("rxrpc", ...)` returns EPERM — seccomp blocks syscall 248
- **Key insight**: The rxrpc module IS loaded and the crypto path is functional. The ONLY missing piece is registering the rxrpc key. If add_key could be bypassed OR if the key could be injected via another path, the exploit would complete.
- **Binary tested**: `dirtyfrag_go` (Go static, 2.2MB)
- **Source**: `1neptune/DirtyFrag`

### 3. CVE-2026-43284 — DirtyFrag ESP variant
- **Status**: FAILED
- **Blocker**: ESP variant needs `fork()` inside Go child process for namespace setup → fails with EPERM
- **Secondary blocker**: Even if fork worked, needs `unshare(NEWUSER|NEWNET)` for sysctl access

### 4. CVE-2026-64564 — SCTPhantom (SCTP ASCONF UAF)
- **Status**: FAILED
- **What works**: `socket(AF_INET, SOCK_STREAM, IPPROTO_SCTP)` ✅ — SCTP works!
- **Blocker 1**: `unshare(CLONE_NEWUSER|CLONE_NEWNET)` returns EPERM
- **Blocker 2**: `socket(AF_PACKET)` returns EPERM — needed for pg_vec heap spray
- **Key insight**: SCTP module loaded (46 users), SCTP sockets work. The Tencent writeup mentions a variant that does NOT need unshare (per-socket SCTP_ASCONF_SUPPORTED), but still needs AF_PACKET for heap spray.
- **Source**: `HackSpeak/CVE-2026-64564`

### 5. CVE-2026-53361 — bad_garbage (AF_UNIX GC vs MSG_PEEK)
- **Status**: PARTIALLY WORKS then FAILED
- **What works**: BTF offsets resolved ✅, SLUB warmup ✅, calibration runs ✅ (30 evaluations)
- **Blocker**: 0 race wins during calibration. Kernel 6.8 uses legacy GC that handles MSG_PEEK differently → PEEK vector not exploitable on 6.8
- **Key insight**: This exploit does NOT use AF_PACKET! It uses UDP sk_buff + pipe_buffer + xattr for spray/reclaim. The framework IS functional on this target. If adapted for the non-PEEK vector (CVE-2026-80521 send+close race), it could work.
- **Source**: `sgkdev/bad_garbage`

### 6. CVE-2026-80521 — AF_UNIX GC UAF (DepthFirst, send+close race)
- **Status**: NOT TESTED (AF_PACKET dependency)
- **Blocker**: DepthFirst exploit uses `AF_PACKET PACKET_RX_RING` mmap for shared ring buffer
- **Key insight**: The BUG exists in kernel 6.8 (confirmed by Ubuntu advisory). The trigger (send+close race on SCM_RIGHTS) uses ONLY allowed syscalls. The problem is exclusively in the POST-UAF exploitation (heap spray/reclaim) which uses AF_PACKET.
- **Source**: `Markakd/Container_escape/pocs/CVE-2026-80521/`

### 7. CVE-2026-52910 — Reuseport BPF (DepthFirst)
- **Status**: NOT TESTED (AF_PACKET dependency)
- **Target**: Ubuntu 24.04 kernel 6.8.0-139-generic (closest to our 6.8.0-90)
- **Blocker**: Uses `AF_PACKET SOCK_RAW` for `PACKET_RX_RING` mmap
- **Source**: `Markakd/Container_escape/pocs/CVE-2026-52910/`

## The Core Challenge

**Every public container escape exploit in 2025-2026 uses `AF_PACKET` for heap spray/reclaim.** Docker's default seccomp profile blocks `AF_PACKET` specifically to prevent this.

We need a **novel heap spray/reclaim primitive** that:
1. Allocates kernel objects of controlled size (matching target slab cache)
2. Provides controlled data content in those objects
3. Works with ONLY the allowed syscalls listed above
4. Can reliably reclaim freed SLUB objects

### Candidate Replacement Primitives

| Primitive | Syscall | Slab Cache | Controllable? | Lifetime |
|-----------|---------|------------|---------------|----------|
| `msg_msg` | `msgsnd()` | kmalloc-* (any size) | YES (full content) | Until `msgrcv()` |
| `setxattr` | `setxattr()` | kmalloc-* (any size) | YES (full content) | Very short (freed immediately after copy) |
| `pipe_buffer` | `pipe()` + `splice()` | pipe_buffer cache (order-0 only) | Partial (page content) | Until pipe drained |
| `sk_buff` | `sendmsg()` AF_UNIX | skbuff_head_cache + kmalloc-* | YES (skb data) | Until `recvmsg()` |
| `simple_xattr` | `setxattr()` on tmpfs | kmalloc-* | YES | Until `removexattr()` |
| `timerfd` | `timerfd_create()` | kmalloc-256 | Limited | Until close |
| `epoll_event` | `epoll_ctl()` | kmalloc-* | Limited | Until epoll_ctl DEL |

### Most Promising Approach

**Adapt `bad_garbage` (CVE-2026-53361) framework** — it already works without AF_PACKET! It uses sk_buff + pipe_buffer + xattr. But it needs:

1. **Replace MSG_PEEK trigger** with CVE-2026-80521 send+close race trigger
2. **Adapt for kernel 6.8 legacy GC** behavior  
3. **Handle order-1 SLUB** (48 CPUs → 32 objs/slab instead of 16)

## SLUB Parameters

```
skbuff_head_cache:
  object_size: 256 bytes
  order: 1 (8KB slabs, because 48 CPUs)
  objs_per_slab: 32
  cpu_partial: 30

kmalloc-96 (unix_vertex target):
  object_size: 96 bytes (struct unix_vertex = 72 bytes)
  order: 0 (estimated)
  objs_per_slab: 42 (estimated)
```

## Files in This Repository

- `target_info/` — Detailed target environment data
- `exploits_tested/` — All exploit source code that was tested
- `syscall_tester/` — Custom syscall availability tester (compiled + source)
- `btf_data/` — BTF type information from target kernel
- `research_notes/` — Analysis and development notes

## Goal

Develop a **working container escape exploit** for kernel 6.8.0-90-generic that uses ONLY allowed syscalls (no AF_PACKET, no add_key, no unshare NEWUSER).
