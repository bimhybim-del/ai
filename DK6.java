import com.jcraft.jsch.*;
import java.io.*;
class DK6 {
  public static void main(String[] a) throws Exception {
    JSch j = new JSch();
    java.util.Properties p = new java.util.Properties();
    p.put("StrictHostKeyChecking", "no");
    Session s = j.getSession("user", "10.14.36.23", 22);
    s.setPassword("kutul0nc4t");
    s.setConfig(p);
    s.setTimeout(10000);
    s.connect();
    // Try SSH to frontend hosts that might be the actual reverse proxy
    String[] targets = {"10.14.3.11","10.14.3.12","10.14.3.13","10.14.3.14"};
    for (String t : targets) {
      try {
        int fwd = s.setPortForwardingL(0, t, 22);
        Session ts = j.getSession("user", "127.0.0.1", fwd);
        ts.setPassword("kutul0nc4t");
        ts.setConfig(p);
        ts.setTimeout(5000);
        ts.connect();
        ChannelExec ch = (ChannelExec) ts.openChannel("exec");
        ch.setCommand("hostname;echo kutul0nc4t | sudo -S grep -rl 'neo\\|noxify\\|payment' /etc/nginx/ /etc/apache2/ /etc/haproxy/ /etc/caddy/ 2>/dev/null | head -5;echo kutul0nc4t | sudo -S grep -rn 'proxy_pass.*neo\\|proxy_pass.*noxify\\|ProxyPass.*neo' /etc/nginx/ /etc/apache2/ /etc/haproxy/ 2>/dev/null | head -10");
        ch.setInputStream(null);
        InputStream in = ch.getInputStream();
        ch.connect();
        System.out.println("=== " + t + " ===");
        byte[] buf = new byte[8192];
        int i;
        while ((i = in.read(buf)) != -1) System.out.write(buf, 0, i);
        ch.disconnect();
        ts.disconnect();
      } catch (Exception e) {
        System.out.println("=== " + t + " === FAIL: " + e.getMessage());
      }
      try { s.delPortForwardingL(s.getPortForwardingL()[s.getPortForwardingL().length-1]); } catch (Exception e) {}
    }
    s.disconnect();
  }
}
