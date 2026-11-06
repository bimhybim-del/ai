import com.jcraft.jsch.*;
import java.io.*;
class SSH6 {
  public static void main(String[] a) throws Exception {
    JSch j = new JSch();
    Session s = j.getSession("user", "10.14.36.23", 22);
    s.setPassword("kutul0nc4t");
    java.util.Properties p = new java.util.Properties();
    p.put("StrictHostKeyChecking", "no");
    s.setConfig(p);
    s.setTimeout(10000);
    s.connect();
    ChannelExec ch = (ChannelExec) s.openChannel("exec");
    ch.setCommand("echo ---RESOLVE---;host payment.accurate.id 2>/dev/null;host account.accurate.id 2>/dev/null;echo ---SCAN-SSH---;for h in 10.14.36.10 10.14.36.11 10.14.36.12 10.14.36.13 10.14.36.20 10.14.36.21 10.14.36.22 10.14.36.24 10.14.36.25 10.14.37.10 10.14.37.11 10.14.38.10 10.13.16.117; do timeout 1 bash -c \"echo > /dev/tcp/$h/22\" 2>/dev/null && echo $h:22-OPEN; done;echo ---DOCKER-IMAGES---;docker images --format '{{.Repository}}:{{.Tag}}' 2>/dev/null | head -20");
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
