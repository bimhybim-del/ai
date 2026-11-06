import com.jcraft.jsch.*;
import java.io.*;
class DK3 {
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
    // Scan key subnets for PostgreSQL port 5432
    ch.setCommand("echo ---SCAN-PG-5432---;for sub in '10.14.16' '10.14.17' '10.14.18' '10.14.19' '10.14.3' '10.14.6' '10.14.7' '10.14.8'; do for i in 10 11 12 13 20 30 40 50 51 52 53; do timeout 1 bash -c \"echo > /dev/tcp/$sub.$i/5432\" 2>/dev/null && echo $sub.$i:5432-OPEN; done; done;echo ---SCAN-PORT-8080---;for sub in '10.14.16' '10.14.17'; do for i in 50 51 52 53; do timeout 1 bash -c \"echo > /dev/tcp/$sub.$i/8080\" 2>/dev/null && echo $sub.$i:8080-OPEN; done; done");
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
