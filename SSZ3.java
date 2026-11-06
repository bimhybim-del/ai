import com.jcraft.jsch.*;
import java.io.*;
class SSZ3 {
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
    ch.setCommand("for h in 10.14.16.51 10.14.16.52 10.14.16.53; do for p in 80 443 8080 8443 8009 8010 9090 3000 4200 5000; do timeout 1 bash -c \"echo > /dev/tcp/$h/$p\" 2>/dev/null && echo $h:$p-OPEN; done; done");
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
