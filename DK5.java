import com.jcraft.jsch.*;
import java.io.*;
class DK5 {
  public static void main(String[] a) throws Exception {
    JSch j = new JSch();
    java.util.Properties p = new java.util.Properties();
    p.put("StrictHostKeyChecking", "no");
    Session s = j.getSession("user", "10.14.36.23", 22);
    s.setPassword("kutul0nc4t");
    s.setConfig(p);
    s.setTimeout(10000);
    s.connect();
    // Hop to reverse proxy 10.14.3.10
    int fwd = s.setPortForwardingL(0, "10.14.3.10", 22);
    try {
      Session rp = j.getSession("user", "127.0.0.1", fwd);
      rp.setPassword("kutul0nc4t");
      rp.setConfig(p);
      rp.setTimeout(8000);
      rp.connect();
      ChannelExec ch = (ChannelExec) rp.openChannel("exec");
      ch.setCommand("hostname;id;echo ---HAPROXY---;echo kutul0nc4t | sudo -S cat /etc/haproxy/haproxy.cfg 2>/dev/null | grep -A3 -iE 'neo|noxify|payment|xendit' | head -30;echo ---NGINX---;echo kutul0nc4t | sudo -S grep -rn 'neo\\|noxify\\|payment' /etc/nginx/ 2>/dev/null | head -20;echo ---APACHE---;echo kutul0nc4t | sudo -S grep -rn 'neo\\|noxify\\|payment' /etc/apache2/ /etc/httpd/ 2>/dev/null | head -20;echo ---CADDY---;echo kutul0nc4t | sudo -S grep -rn 'neo\\|noxify\\|payment' /etc/caddy/ 2>/dev/null | head -20");
      ch.setInputStream(null);
      InputStream in = ch.getInputStream();
      ch.connect();
      byte[] buf = new byte[8192];
      int i;
      while ((i = in.read(buf)) != -1) System.out.write(buf, 0, i);
      ch.disconnect();
      rp.disconnect();
    } catch (Exception e) {
      System.out.println("RP_FAIL: " + e.getMessage());
    }
    s.disconnect();
  }
}
