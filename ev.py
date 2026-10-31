#!/usr/bin/env python3
import struct, sys, os

vmlinuz = open("/tmp/kimg/boot/vmlinuz-6.17.0-1019-aws", "rb").read()
print(f"vmlinuz size: {len(vmlinuz)}")

# Find zstd magic
zstd_magic = b'\x28\xb5\x2f\xfd'
idx = vmlinuz.find(zstd_magic)
if idx >= 0:
    print(f"zstd at offset {idx} (0x{idx:x})")
    compressed = vmlinuz[idx:]
    with open("/tmp/vmlinuz_payload.zst", "wb") as f:
        f.write(compressed)
    os.system("zstd -d /tmp/vmlinuz_payload.zst -o /tmp/vmlinux --force 2>&1")
    if os.path.getsize("/tmp/vmlinux") > 0:
        vmlinux = open("/tmp/vmlinux", "rb").read()
        print(f"vmlinux: {len(vmlinux)} bytes")
        
        # Find core_pattern variable address
        # Look for the string "core" as the default core_pattern value
        # In .data section, core_pattern default = "core"
        pattern = b"core\x00"
        results = []
        off = 0
        while True:
            idx2 = vmlinux.find(pattern, off)
            if idx2 < 0: break
            # Check surrounding context
            before = vmlinux[max(0,idx2-16):idx2]
            after = vmlinux[idx2:idx2+32]
            results.append(idx2)
            off = idx2 + 1
        
        print(f"Found 'core' at {len(results)} locations")
        # core_pattern is in .data section, look for 128-byte aligned buffer
        for r in results[:20]:
            # core_pattern is a char[128] buffer
            # Check if followed by nulls (buffer initialized to "core\0\0\0...")
            if vmlinux[r:r+5] == b'core\x00' and vmlinux[r+5:r+20] == b'\x00' * 15:
                # Likely core_pattern buffer
                addr = 0xffffffff81000000 + r
                offset_from_stext = r
                print(f"  LIKELY core_pattern at vmlinux offset 0x{r:x} = kernel addr 0x{addr:x}")
                print(f"  CORE_PATTERN_OFFSET = 0x{offset_from_stext:x}")
else:
    # Try gzip
    gzip_magic = b'\x1f\x8b\x08'
    idx = vmlinuz.find(gzip_magic)
    if idx >= 0:
        print(f"gzip at offset {idx}")
        compressed = vmlinuz[idx:]
        with open("/tmp/vmlinuz_payload.gz", "wb") as f:
            f.write(compressed)
        os.system("gzip -dc /tmp/vmlinuz_payload.gz > /tmp/vmlinux 2>/dev/null")
    else:
        print("No compression marker found")
