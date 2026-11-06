import com.jcraft.jsch.*;
import java.io.*;
class DK7 {
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
    // Try from internaltools directly via sshpass
    ch.setCommand("for h in 10.14.3.11 10.14.3.12 10.14.3.13 10.14.3.14; do echo === $h ===; sshpass -p kutul0nc4t ssh -o StrictHostKeyChecking=no -o ConnectTimeout=3 user@$h 'hostname;sudo grep -rn \"neo\\|noxify\\|payment\\|xendit\" /etc/haproxy/ /etc/nginx/ /etc/apache2/ 2>/dev/null | head -10' 2>&1 | head -15; done");
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
