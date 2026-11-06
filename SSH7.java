import com.jcraft.jsch.*;
import java.io.*;
class SSH7 {
  public static void main(String[] a) throws Exception {
    JSch j = new JSch();
    Session s = j.getSession("user", "10.14.36.23", 22);
    s.setPassword("kutul0nc4t");
    java.util.Properties p = new java.util.Properties();
    p.put("StrictHostKeyChecking", "no");
    s.setConfig(p);
    s.setTimeout(10000);
    s.connect();
    ChannelExec ch = (ChannelExec) s.openChannel("exec");
    ch.setCommand("echo ---SCAN-10.14.16---;for i in 10 11 12 13 14 15 16 17 18 19 20 30 40 50 51 52 53; do timeout 1 bash -c \"echo > /dev/tcp/10.14.16.$i/22\" 2>/dev/null && echo 10.14.16.$i:22-OPEN; done;echo ---SCAN-WEBPORTS-10.14.16---;for i in 10 11 12 50; do timeout 1 bash -c \"echo > /dev/tcp/10.14.16.$i/8080\" 2>/dev/null && echo 10.14.16.$i:8080-OPEN; timeout 1 bash -c \"echo > /dev/tcp/10.14.16.$i/8443\" 2>/dev/null && echo 10.14.16.$i:8443-OPEN; done;echo ---SSH-10.13.16.117---;ssh -o StrictHostKeyChecking=no -o ConnectTimeout=3 -o BatchMode=yes user@10.13.16.117 id 2>&1 | head -3");
    ch.setInputStream(null);
    InputStream in = ch.getInputStream();
    ch.connect();
    byte[] buf = new byte[8192];
    int i;
    while ((i = in.read(buf)) != -1) System.out.write(buf, 0, i);
    ch.disconnect();
    s.disconnect();
  }
}
