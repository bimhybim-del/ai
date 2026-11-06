import com.jcraft.jsch.*;
import java.io.*;
class DKB {
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
    ch.setCommand("echo ---S-SH---;echo kutul0nc4t | sudo -S cat /tmp/s.sh 2>/dev/null;echo ---DOCKER-VOLUMES---;echo kutul0nc4t | sudo -S ls /var/lib/docker/volumes/ 2>/dev/null | head -20;echo ---VAULT-FILES---;echo kutul0nc4t | sudo -S find / -maxdepth 4 -name 'vault*' -o -name '.vault-token' -o -name 'vault.hcl' 2>/dev/null | grep -v proc | head -10");
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
