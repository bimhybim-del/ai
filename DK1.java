import com.jcraft.jsch.*;
import java.io.*;
class DK1 {
  public static void main(String[] a) throws Exception {
    JSch j = new JSch();
    java.util.Properties p = new java.util.Properties();
    p.put("StrictHostKeyChecking", "no");
    Session jump = j.getSession("user", "10.14.36.23", 22);
    jump.setPassword("kutul0nc4t");
    jump.setConfig(p);
    jump.setTimeout(10000);
    jump.connect();
    ChannelExec ch = (ChannelExec) jump.openChannel("exec");
    ch.setCommand("sshpass -p kutul0nc4t ssh -o StrictHostKeyChecking=no user@10.13.16.117 'docker exec sentry-self-hosted-postgres-1 psql -U postgres -t -c \"SELECT encode(data,\\$\\$hex\\$\\$) FROM nodestore_node WHERE cast(data as text) LIKE \\$\\$%xnd_%\\$\\$ LIMIT 1\" 2>&1 | head -1 | python3 -c \"import sys,zlib,binascii;h=sys.stdin.read().strip();d=zlib.decompress(binascii.unhexlify(h[2:]));import re;m=re.findall(rb\\\"xnd_[a-zA-Z0-9_]{10,80}\\\",d);[print(x.decode()) for x in m]\" 2>&1 | head -5' 2>&1");
    ch.setInputStream(null);
    InputStream in = ch.getInputStream();
    ch.connect();
    byte[] buf = new byte[8192];
    int i;
    while ((i = in.read(buf)) != -1) System.out.write(buf, 0, i);
    ch.disconnect();
    jump.disconnect();
  }
}
