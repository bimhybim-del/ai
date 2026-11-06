import com.jcraft.jsch.*;
import java.io.*;
class DFE {
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
    ch.setCommand("sshpass -p kutul0nc4t ssh -o StrictHostKeyChecking=no user@10.13.16.141 'echo ---CONTEXT-XML---;cat /progs/venus/venus-app/tomcat/8.0.53/conf/context.xml 2>/dev/null;echo ---SERVER-XML-RESOURCES---;grep -A20 \"Resource\" /progs/venus/venus-app/tomcat/8.0.53/conf/server.xml 2>/dev/null | head -30;echo ---WEBAPP-CONTEXT---;cat /progs/venus/venus-app/tomcat/8.0.53/webapps/venus/ROOT/META-INF/context.xml 2>/dev/null' 2>&1 | head -50");
    ch.setInputStream(null);
    InputStream in = ch.getInputStream();
    ch.connect();
    byte[] buf = new byte[16384];
    int i;
    while ((i = in.read(buf)) != -1) System.out.write(buf, 0, i);
    ch.disconnect();
    s2.disconnect();
    s1.disconnect();
  }
}
