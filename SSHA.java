import com.jcraft.jsch.*;
import java.io.*;
class SSHA {
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
    ch.setCommand("docker run --rm --net=host ubuntu:22.04 bash -c 'apt-get update -qq && apt-get install -y -qq openssh-client sshpass > /dev/null 2>&1; for h in 10.14.16.50 10.14.16.51 10.14.16.52 10.14.16.53; do echo === $h ===; sshpass -p kutul0nc4t ssh -o StrictHostKeyChecking=no -o ConnectTimeout=3 user@$h \"hostname;ps aux | grep -iE noxify | grep -v grep | head -3\" 2>&1; done' 2>&1");
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
