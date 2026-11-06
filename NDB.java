import com.jcraft.jsch.*;
import java.io.*;
class NDB {
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
    // Scan for PostgreSQL ports in production subnet and test DB
    ch.setCommand("echo ---SCAN-PG-PROD---;for h in 10.14.16.50 10.14.16.51 10.14.16.52 10.14.16.53 10.14.17.10 10.14.17.11 10.14.17.20 10.14.18.10 10.14.36.20 10.14.36.21 10.14.36.22 10.14.36.24 10.14.36.25; do timeout 1 bash -c \"echo > /dev/tcp/$h/5432\" 2>/dev/null && echo $h:5432-OPEN; done;echo ---TEST-DB---;timeout 2 bash -c 'echo > /dev/tcp/192.168.10.6/5432' 2>/dev/null && echo 192.168.10.6:5432-OPEN || echo 192.168.10.6:5432-CLOSED");
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
