import com.jcraft.jsch.*;
import java.io.*;
class DK4 {
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
    ch.setCommand("for h in 10.14.17.10 10.14.17.11 10.14.17.20 10.14.17.50 10.14.18.10 10.14.18.20 10.14.18.50 10.14.19.10 10.14.19.20; do timeout 1 bash -c \"echo > /dev/tcp/$h/5432\" 2>/dev/null && echo $h:5432-PG; done;for h in 10.14.6.10 10.14.6.20 10.14.6.30 10.14.7.10 10.14.7.20 10.14.8.10 10.14.8.20; do timeout 1 bash -c \"echo > /dev/tcp/$h/5432\" 2>/dev/null && echo $h:5432-PG; done");
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
