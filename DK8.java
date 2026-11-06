import com.jcraft.jsch.*;
import java.io.*;
class DK8 {
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
    // Scan for container orchestration APIs
    ch.setCommand("echo ---PORTAINER---;for h in 10.14.16.50 10.14.16.51 10.14.16.52 10.14.16.53 10.14.16.10 10.14.16.11 10.14.36.10 10.14.36.11 10.14.36.12; do for p in 9000 9443 2377 6443 8443 10250; do timeout 1 bash -c \"echo > /dev/tcp/$h/$p\" 2>/dev/null && echo $h:$p-OPEN; done; done;echo ---RESOLVE---;host portainer.internaltools.biz 2>/dev/null;host rancher.internaltools.biz 2>/dev/null;host k8s.internaltools.biz 2>/dev/null;host docker.internaltools.biz 2>/dev/null;host vault.internaltools.biz 2>/dev/null");
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
