import com.jcraft.jsch.*;
import java.io.*;
class XMB {
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
    ch.setCommand("sshpass -p kutul0nc4t ssh -o StrictHostKeyChecking=no user@10.13.16.117 'sshpass -p kutul0nc4t ssh -o StrictHostKeyChecking=no user@10.13.16.186 \"echo ---CONTEXT-XML---;cat /progs/noxify/noxify-app/tomcat/7.0.109/conf/context.xml 2>/dev/null;echo ---NOXIFY-CONTEXT---;cat /progs/noxify/noxify-app/tomcat/7.0.109/webapps/noxify/ROOT/META-INF/context.xml 2>/dev/null;echo ---SERVER-XML---;grep -A10 \\\"Resource\\\\|DataSource\\\" /progs/noxify/noxify-app/tomcat/7.0.109/conf/server.xml 2>/dev/null | head -20;echo ---GREP-DB-ALL---;grep -rn \\\"jdbc\\\\|DataSource\\\\|db\\\\.pass\\\" /progs/noxify/noxify-app/tomcat/7.0.109/conf/ 2>/dev/null | head -10\" 2>&1' 2>&1 | head -50");
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
