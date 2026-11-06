import com.jcraft.jsch.*;
import java.io.*;
class XSW {
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
    // Use netstat to find actual DB connection from Accurate process
    ch.setCommand("sshpass -p kutul0nc4t ssh -o StrictHostKeyChecking=no user@10.13.16.132 'echo ---ACTUAL-DB-CONN---;echo kutul0nc4t | sudo -S ss -tnp | grep 439985 | grep 5501;echo ---ALSO-5432---;echo kutul0nc4t | sudo -S ss -tnp | grep 439985 | grep 5432;echo ---ALL-DB-CONN---;echo kutul0nc4t | sudo -S ss -tnp | grep 439985 | grep -E \"5432|5501|3306\" | head -5;echo ---ENVIRONMENT-FILE---;cat /progs/accurate/accurate-app/tomcat/8.0.53/environment 2>/dev/null | grep -iE \"db|pass|ENC|ACC\"' 2>&1");
    ch.setInputStream(null);
    InputStream in = ch.getInputStream();
    ch.connect();
    byte[] buf = new byte[8192];
    int i;
    while ((i = in.read(buf)) != -1) System.out.write(buf, 0, i);
    ch.disconnect();
    s2.disconnect();
    s1.disconnect();
  }
}
