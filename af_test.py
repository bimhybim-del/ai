#!/usr/bin/env python3
import socket
try:
    a = socket.socket(38, 5, 0)
    print("AF_ALG_AVAILABLE")
    a.close()
except Exception as e:
    print("AF_ALG_BLOCKED:" + str(e))

import sys
print("PYTHON:" + sys.version.split()[0])

import os
# Check SUID
for p in ["/bin/su","/usr/bin/su","/usr/bin/passwd","/usr/bin/newgrp"]:
    if os.path.exists(p):
        st = os.stat(p)
        if st.st_mode & 0o4000:
            print("SUID:" + p)

# Check splice
try:
    r, w = os.pipe()
    os.write(w, b"test")
    print("PIPE_OK")
    os.close(r)
    os.close(w)
except:
    print("PIPE_FAIL")
