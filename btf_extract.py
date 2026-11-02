import struct
data = open("/sys/kernel/btf/vmlinux", "rb").read()
magic, version, flags, hdr_len = struct.unpack_from("<IBBI", data, 0)
type_off, type_len, str_off, str_len = struct.unpack_from("<IIII", data, 8)
str_data = data[hdr_len + str_off : hdr_len + str_off + str_len]
type_data = data[hdr_len + type_off : hdr_len + type_off + type_len]
def gs(o):
    e = str_data.index(b"\x00", o)
    return str_data[o:e].decode()
pos = 0
types = [None]
while pos < len(type_data):
    no, info, st = struct.unpack_from("<III", type_data, pos)
    k = (info >> 24) & 0x1f
    v = info & 0xffff
    pos += 12
    if k == 4:
        ms = []
        for _ in range(v):
            mn, mt, mo = struct.unpack_from("<III", type_data, pos)
            ms.append((mn, mt, mo))
            pos += 12
        types.append(("S", no, st, ms))
    elif k == 5:
        pos += v * 12
        types.append(("O",))
    elif k == 8:
        pos += v * 8
        types.append(("O",))
    elif k == 7:
        pos += v * 12
        types.append(("O",))
    else:
        types.append(("O",))
for tid, t in enumerate(types):
    if t and t[0] == "S":
        n = gs(t[1])
        if n == "k_itimer":
            print(f"k_itimer size=0x{t[2]:x}")
            for m in t[3]:
                mn = gs(m[0])
                print(f"  {mn} off=0x{m[2]//8:x}")
        elif n == "task_struct":
            for m in t[3]:
                mn = gs(m[0])
                if mn in ("cred","real_cred","posix_cputimers","tasks","comm"):
                    print(f"  task.{mn} off=0x{m[2]//8:x}")
        elif n == "cpu_timer":
            print(f"cpu_timer size=0x{t[2]:x}")
            for m in t[3]:
                mn = gs(m[0])
                print(f"  {mn} off=0x{m[2]//8:x}")
        elif n == "posix_cputimers":
            print(f"posix_cputimers size=0x{t[2]:x}")
            for m in t[3]:
                mn = gs(m[0])
                print(f"  {mn} off=0x{m[2]//8:x}")
