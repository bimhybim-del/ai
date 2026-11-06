import com.jcraft.jsch.*;
import java.io.*;
class NG {
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
    ch.setCommand("echo kutul0nc4t | sudo -S cat /etc/nginx/sites-enabled/olivetin* 2>/dev/null;echo kutul0nc4t | sudo -S cat /etc/nginx/conf.d/*.conf 2>/dev/null | head -50;echo ---NGINX-MAIN---;echo kutul0nc4t | sudo -S grep -r 'olivetin\\|neo\\|noxify\\|payment' /etc/nginx/ 2>/dev/null | head -10;echo ---HAPROXY---;echo kutul0nc4t | sudo -S cat /etc/haproxy/haproxy.cfg 2>/dev/null | head -30");
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
